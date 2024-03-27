% input:
oldFolder = cd('C:\Users\martin\dev\ds\');
ref_data = abcds.data.robot_rec('datasets/robot_recordings/gbin/reference_trajectories6.txt', dims_to_keep=1:6, type='6d', preprocess_args=struct('cut_begin', 100, 'cut_end', 0, 'movemean', true));
cd(oldFolder);
dim1 = 1;
dim2 = 2;
pos = {};
for n = 1:length(ref_data.pos)
    pos{n} = ref_data.pos{n}([dim1, dim2], :);
end
limit_fact = 0.2; % or lower and upper bounds
num_samples = 2000;
rng(1, 'twister');
weight_in_poly = 1;
weight_not_in_poly = 8;
include_ref_data_points = true;
include_poly_points = true;
precision = 16;

% fixed params (for now):
dim = 2;

fig = figure;

%% show ref data
for n = 1:length(pos)
    plot(pos{n}(dim1, :), pos{n}(dim2, :), 'color', '#3392ff', 'linewidth', 1, 'handlevisibility', 'off');
    hold on;
end
axis equal;

Pos = cat(2, pos{:});

min_vals = min(Pos, [], 2);
max_vals = max(Pos, [], 2);
range_vals = max_vals - min_vals;
xy_range = max(range_vals);
lower_lims = min_vals - xy_range * limit_fact;
upper_lims = max_vals + xy_range * limit_fact;
limits = ([lower_lims, upper_lims]');
limits = limits(:)';

xlim([limits((dim1 - 1)*2+1), limits((dim1 - 1)*2+2)]);
ylim([limits((dim2 - 1)*2+1), limits((dim2 - 1)*2+2)]);

%% draw polygon(s)
polygons = {};
num_polys = 2;
for i = 1:num_polys
    polygons{i} = drawpolygon('color', 'black', 'FaceAlpha', 0.25);
    polygons{i}.Color = 'black';
end

%% get sample points
samples = [];
labels = [];
weights = [];

samples = rand(num_samples, dim) .* [repmat(upper_lims(dim1) - lower_lims(dim1), num_samples, 1), repmat(upper_lims(dim2) - lower_lims(dim2), num_samples, 1)] + [repmat(lower_lims(dim1), num_samples, 1), repmat(lower_lims(dim2), num_samples, 1)];
% x = linspace(lowerlimx, upperlimx, 50);
% y = linspace(lowerlimy, upperlimy, 50);
% num_samples = 50*50;
% [X,Y] = meshgrid(x,y);
% samples = [X(:), Y(:)];

labels = -1 * ones(num_samples, 1);
weights = weight_in_poly * ones(num_samples, 1);
cur_poly_points = polygons{1}.Position;
tmp = inpolygon(samples(:, 1), samples(:, 2), cur_poly_points(:, 1), cur_poly_points(:, 2));
for i = 2:length(polygons)
    cur_poly_points = polygons{i}.Position;
    tmp = tmp + inpolygon(samples(:, 1), samples(:, 2), cur_poly_points(:, 1), cur_poly_points(:, 2));
end
are_in_poly = logical(tmp);
labels(are_in_poly) = 1;
% weights(are_in_poly) = weight_in_poly;
weights(~are_in_poly) = weight_not_in_poly;

% are_in_poly_tmp = logical(inpolygon(samples(:, 1), samples(:, 2), polypoints1(:, 1), polypoints1(:, 2)));
% weights(are_in_poly_tmp) = 8;

% add ref traj points
if include_ref_data_points
    samples = [samples; Pos'];
    labels = [labels; -1 * ones(size(Pos', 1), 1)];
    weights = [weights; 2 * ones(size(Pos', 1), 1)];
end

% add obstacle vertices
if include_poly_points
    for i = 1:length(polygons)
        cur_poly_points = polygons{i}.Position;
        samples = [samples; cur_poly_points];
        labels = [labels; ones(size(cur_poly_points, 1), 1)];
        weights = [weights; 2 * ones(size(cur_poly_points, 1), 1)];
    end
end

scatter(samples(:, 1), samples(:, 2), labels+2);

% weights(weights > 1) = 8;
% weights(labels == 1) = 8;

approach = 'pss';
switch approach
    case 'svm'
        if ~exist('svm.m')
            addpath('svm');
        end
        p = svm(samples, labels, weights);
    case 'pss'
        if ~exist('pss.m')
            addpath('pss');
        end
        p = pss(samples(labels == 1, :));
end

%%
% fcontour(formula(p), limits, 'LevelList', 0:0, 'MeshDensity', 1000, 'linecolor', 'red', 'linewidth', 2);
fimplicit(formula(p), limits, 'color', 'red', 'linewidth', 2);

%% optional: plot surface function of computed polynomial
% figure;
% fsurf(res, [-10, 10, -10, 10]);

%% polynomial to file
filename = 'tmp_poly.mat';
save(filename, 'p', '-mat');
file = which(filename);

%% polynomial from file
p_tmp = load(file, '-mat');
p_loaded = p_tmp.p;
