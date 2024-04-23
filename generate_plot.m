if ~exist('setup_figure2')
    addpath("plotting");
end

[fig, UIAxes] = setup_figure2(2*3.41275152778, 2*3.41275152778, true);
clc
% set(0,'defaulttextinterpreter','latex')
% set(0,'DefaultTextFontSize', 10)
% set(0,'DefaultTextFontname', 'CMU Serif')
% set(0,'DefaultAxesFontSize', 10)
% set(0,'DefaultAxesFontName','CMU Serif')

hold(UIAxes, 'on');


limits = [-0.3111,1.2988,-0.3094,0.7571];
xlim(UIAxes, limits(1:2));
ylim(UIAxes, limits(3:4));


ref_data = readmatrix('tmp_refdata.txt');

xlimits = UIAxes.XLim;
ylimits = UIAxes.YLim;

ref_data_scatter = scatter(UIAxes, ref_data(:, 1), ref_data(:, 2), 1, 'black', 'HandleVisibility', 'off');


polygons_tmp = {};
polygons_tmp{end+1} = [0.8039,-0.1370;0.8039,0.3049;0.7294,0.3049;0.7294,-0.1370];
polygons_tmp{end+1} = [0.8039,-0.1370;0.8039,-0.0390;0.2169,-0.0390;0.2169,-0.1370];
polygons_tmp{end+1} = [0.2915,-0.1370;0.2915,0.3049;0.2169,0.3049;0.2169,-0.1370];
polygons = {};
for i = 1:length(polygons_tmp)
    polygons{end+1} = drawpolygon(UIAxes, 'color', 'black', 'FaceAlpha', 0, 'EdgeAlpha', 0, 'Position', polygons_tmp{i});
    polygons{end}.Color = 'black';

    pgon = polyshape(polygons_tmp{i}(:,1), polygons_tmp{i}(:,2));
    tmp_pgon_3 = plot(pgon, 'EdgeColor', 'black', 'FaceColor', 'black', 'FaceAlpha', 0, 'LineWidth', 2, 'displayname', 'Polygon for encloSOS');
    if i > 1
        set(tmp_pgon_3, 'handlevisibility', 'off');
    end
end




P2 = [[14.75; 0], [14.75; 27.9], [13.4; 27.9], [13.4; 0]];
P3 = [[14.75; 0], [14.75; 2.3], [-14.75; 2.3], [-14.75; 0]];
P4 = [[-13.4; 0], [-13.4; 27.9], [-14.75; 27.9], [-14.75; 0]];

offset_vect_x3 = [5; 0];
P2 = P2 + offset_vect_x3;
offset_vect_x4 = [1, 1, -1, -1] .* offset_vect_x3;
P3 = P3 + offset_vect_x4;
P4 = P4 - offset_vect_x3;


translation_vect = [38; -5.2];  % large box
P2 = P2 + translation_vect;
P3 = P3 + translation_vect;
P4 = P4 + translation_vect;

% convert to meters
P2 = P2 ./ 100;
P3 = P3 ./ 100;
P4 = P4 ./ 100;

obstacle_expansion_fact = 0.0; % meters
offset_vect_x = [1, 1, -1, -1] * obstacle_expansion_fact;
offset_vect_y = [-1, 0, 0, -1] * 0.0;
offset_vect = [offset_vect_x; offset_vect_y];

P2 = P2 + offset_vect;
P3 = P3 + offset_vect;
P4 = P4 + offset_vect;

P5 = [P2(:, 1:3), [P2(1, 4); P2(2, 4) + 0.023], [P4(1, 1); P4(2, 1) + 0.023], P4(:, 2:4)];

obstacle_polygon_cellarr = {};
obstacle_polygon_cellarr{1} = P5;

pgon = {};
for pi = 1:length(obstacle_polygon_cellarr)
    pgon_tmp= obstacle_polygon_cellarr{pi};
    pgon_tmp = pgon_tmp ./ rd.state_maxnorm;
    pgon{pi} = polyshape(pgon_tmp(1,:), pgon_tmp(2,:));
end
for pi = 1:length(pgon)
    plt_pgon1 = plot(pgon{pi}, 'linewidth', 2, 'linestyle', ':', 'edgecolor', 'yellow', 'facecolor', 'yellow', 'facealpha', 0, 'displayname', 'Obstacle');
    % set(plt_pgon1, 'handlevisibility', 'off');
end




xlim(UIAxes, xlimits);
ylim(UIAxes, ylimits);

dim = 2;

samples = [];
labels = [];
weights = [];

rng(1, 'twister');
weight_in_poly = 8;
weight_not_in_poly = 2;
include_poly_points = true;

sampling_method = 'grid';
switch sampling_method
    case 'random'
        num_samples = 2000;
        samples = rand(num_samples, dim) .* [repmat(xlimits(2) - xlimits(1), num_samples, 1), repmat(ylimits(2) - ylimits(1), num_samples, 1)] + [repmat(xlimits(1), num_samples, 1), repmat(ylimits(1), num_samples, 1)];
    case 'grid'
        tmp_value = [50,50];
        x = linspace(xlimits(1), xlimits(2), tmp_value(1));
        y = linspace(ylimits(1), ylimits(2), tmp_value(2));
        num_samples = tmp_value(1)*tmp_value(2);
        [X,Y] = meshgrid(x,y);
        samples = [X(:), Y(:)];
end

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

% add negative datapoints
use_ref_data = true;
if ~isempty(ref_data) && use_ref_data
    samples = [samples; ref_data];
    labels = [labels; -1 * ones(size(ref_data, 1), 1)];
    weights = [weights; weight_not_in_poly * ones(size(ref_data, 1), 1)];
end

% add obstacle vertices
if include_poly_points
    for i = 1:length(polygons)
        cur_poly_points = polygons{i}.Position;
        samples = [samples; cur_poly_points];
        labels = [labels; ones(size(cur_poly_points, 1), 1)];
        weights = [weights; weight_in_poly * ones(size(cur_poly_points, 1), 1)];
    end
end

samples_scatter = scatter(UIAxes, samples(:, 1), samples(:, 2), labels+2, 'blue', 'displayname', 'Sample points');

load_from_file = true;
if load_from_file
    p = load('tmp_poly');
    p = p.p;
else
    poly_deg = 4;
    approach = 'SVM';
    switch approach
        case 'SVM'
            if ~exist('svm.m')
                addpath('svm');
            end
            p = svm(samples, labels, weights, deg=poly_deg, boxconstraint=1600, kernelscale=0.48);
        case 'PSS'
            if ~exist('pss.m')
                addpath('pss');
            end
            p = pss(samples(labels == 1, :), deg=poly_deg);
        case 'EM'
            if ~exist('em.m')
                addpath('em');
            end
            p = em(samples(labels == 1, :), deg=poly_deg, delta=0);
    end
end

disp(['p(x1, x2) = ' char(p)]);

% levelcurve_line = fimplicit(UIAxes, formula(p), [xlimits, ylimits], 'color', 'red', 'linewidth', 2, 'HandleVisibility', 'off');

%%
[options, result, f, V, B] = read_exp('plotting/2023-09-28_033613');

exp_list = options.dataset_opts.exp_list;
exp_list_cellarr = fileread(fullfile('c:/users/martin/dev/ds', exp_list, 'reference_trajectories.txt'));
exp_list_cellarr = regexp(exp_list_cellarr, '\r\n|\r|\n', 'split');

for i = 1:length(exp_list_cellarr)
    exp_list_cellarr{i} = ['c:/users/martin/dev/ds/', exp_list_cellarr{i}];
end

[Data, Target, indivTrajStartIndices, timestamps] = recorded_trajectories_to_refdata(exp_list_cellarr, 100, "record", true);
M = 2;
shift = Target;
Data(1:M, :) = Data(1:M, :) - shift;
Target = [0; 0];
rd = RefData;
rd.directInit(Data, Target, indivTrajStartIndices, timestamps, true);


initial_set_center = rd.xi0_mean;
initial_set_radius = 0.05;

workspace = [[-1; -0.5], [0.5; 1]];


xi = sdpvar(rd.M, 1);

% initial/safe set
r1 = initial_set_radius;
r21 = r1 * r1;
center1 = initial_set_center;
initial_set = {};
initial_set{1} = r21 - sum((xi-center1).^2, 1);

% unsafe set
unsafe_set = {};
[unsafe_set_coefs, unsafe_set_monomials] = file2poly('plotting/unsafe_set_poly.json', xi);
unsafe_set{1} = dot(unsafe_set_coefs, unsafe_set_monomials);


plot_dim1 = 1;
plot_dim2 = 2;

% [fig, ax] = setup_figure2(3.41275152778, 3.41275152778, false);
fontsize(fig, 7, "points");
box on;
xlh = xlabel(strcat('$\xi_', int2str(plot_dim2), '$'), 'interpreter','latex');
ylh = ylabel(strcat('$\xi_', int2str(plot_dim1), '$'), 'interpreter','latex');


% reference trajectories and equilibrium
scatter([], [], 0.001, 'o', 'sizedata', 0.001, 'markeredgecolor', 'black', 'markerfacecolor', 'black', 'linewidth', 0.001, 'displayname', 'Equilibrium $\xi^*$');
plot_objs = rd.plotLines(plot_dim1, plot_dim2, {'sizedata', 20, 'handlevisibility', 'off'}, {'linewidth', 0.5, 'color', 'none', 'handlevisibility', 'off'});
plot_objs2 = rd.plot_lines_presentation(plot_dim1, plot_dim2, {'color', 'none', 'handlevisibility', 'off'}, {'linewidth', 1, 'displayname', 'Reference trajs. $\xi^{\mathrm{ref}}$'});
quiver(100,100,1,0, 'black', 'linewidth', 0.5, 'displayname', 'Dyn. sys. $f(\xi)$');

% axis limits (depending on ref data)
xlim([limits(1), limits(2)]);
ylim([limits(3), limits(4)]);
axis_limits = axis;


% plot DS
streamlines_plt = plot_streamlines_for_f(f, axis_limits, 200, 2);
% set(streamlines_plt, 'linewidth', 1);
set(streamlines_plt(1), 'displayname', '$f(\xi)$');
set(streamlines_plt(1), 'handlevisibility', 'off');
set(streamlines_plt(2:end), 'handlevisibility', 'off');

resolution = 0.01;
[X, Y] = meshgrid(axis_limits(1)-resolution:resolution:axis_limits(2)+resolution, axis_limits(3)-resolution:resolution:axis_limits(4)+resolution);
XY = [X(:)'; Y(:)'];


% plot Barrier zero-level curve
if options.enable_barrier
    % plot initial set
    for p = 1:length(initial_set)
        fgptilde = sdpvar2fun(initial_set{p}, xi);
        Fgptilde = reshape(fgptilde(XY), size(X));
        [cctilde, hhtilde] = contourf(X, Y, Fgptilde, [0, 0], 'linewidth', 1, 'color', 'cyan', 'facecolor', 'cyan', 'facealpha', 0.35, 'displayname', strcat('$\mathcal{X}_{0}$'), 'handlevisibility', 'off');
        hold on;
    end
    fill([10 10 100 100],[10 100 100 10], 'cyan', 'edgecolor', 'cyan', 'facecolor', 'cyan', 'facealpha', 0.35, 'displayname', 'Initial set $\mathcal{X}_{0}$');
    
    % plot unsafe set
    for m = 1:length(unsafe_set)
        fgm = sdpvar2fun(unsafe_set{m}, xi);
        Fgm = reshape(fgm(XY), size(X));
        [cc, hh] = contourf(X, Y, Fgm, [0, 0], 'linewidth', 1, 'color', 'black', 'facecolor', 'black', 'facealpha', 0.35, 'displayname', strcat('$\mathcal{X}_{u}$'), 'handlevisibility', 'off');
        hold on;
    end
    fill([10 10 100 100],[10 100 100 10], 'black', 'edgecolor', 'black', 'facecolor', 'black', 'facealpha', 0.35, 'displayname', 'Unsafe set $\mathcal{X}_{u}$');
    

    Bfun_eval = reshape(B(XY), size(X));

    % plot certified safe region
    color_tmp = '#4CBB17';
    facealpha_tmp = 0.25;
    [~, plt_saferegion] = contourf(X, Y, -Bfun_eval, [0, 0], 'linewidth', 1, 'color', 'none', 'facecolor', color_tmp, 'facealpha', facealpha_tmp, 'handlevisibility', 'off');
    uistack(plt_saferegion, 'bottom');
    hold on;
    fill([10 10 100 100],[10 100 100 10], 'g', 'edgecolor', 'none', 'facecolor', color_tmp, 'facealpha', facealpha_tmp, 'displayname', 'Certified safe set $\mathcal{X}_s$');
    
    % plot barrier 0-level set
    contour(X, Y, Bfun_eval, [0, 0], 'linewidth', 1, 'color', '#d41919', 'displayname', 'Barrier $B^{-1}(0)$');
    hold on;
end



uistack(plt_pgon1, 'top');



% % actual trajectories based on executing the DS on the robot
% sim_path = sim_id;
% [Data3, Target3, indivTrajStartIndices3, timestamps3] = recorded_trajectories_to_refdata({sim_path}, 0, "eval");
% M3 = 2;
% shift3 = shift;
% Data3(1:M3, :) = Data3(1:M3, :) - shift3;
% Target3 = Target3 - shift3;
% rd3 = RefData;
% rd3.directInit(Data3, Target3, indivTrajStartIndices3, timestamps3, true, rd.state_maxnorm, rd.vel_maxnorm);
% 
% % generate sample trajectories
% initial_set_center_est = rd3.xi0_mean;
% 
% rd_est = RefData;
% [Data_est, Target_est, indivTrajStartIndices_est, Timestamps_est] = generateRefData(f, initial_set_center_est);
% rd_est.directInit(Data_est, Target_est, indivTrajStartIndices_est, Timestamps_est, false);
% plt_sampled_traj = rd_est.plotLines(plot_dim1, plot_dim2, {'markeredgecolor', 'none', 'markerfacecolor', 'none', 'handlevisibility', 'off'}, {'color', '#ff00ff', 'linewidth', 1.5, 'displayname', 'Generated traj. $\xi^{\mathrm{gen}}$'});

% rd3.plotLines(1, 2, {'markeredgecolor', 'none', 'markerfacecolor', 'none', 'handlevisibility', 'off'}, {'color', '#3392ff', 'linewidth', 1, 'displayname', 'Actual traj. $\xi^{\mathrm{actual}}$'});


leg = findobj(fig, 'Type', 'Legend');
leg.ItemTokenSize(1) = 5;



%%
plot_id = 'showcase';
output_root_path = 'output/';
% figure_to_file2(fig, fullfile(output_root_path, plot_id), format='-dpdf');
figure_to_file2(fig, fullfile(output_root_path, plot_id), format='-dpng');
close(fig);