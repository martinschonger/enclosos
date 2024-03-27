function p = pss(points_in_set, args)

arguments
    points_in_set % points inside the semi-algebraic set
    args.deg = 4 % degree of the polynomial p_tmp of the PSS
end

% Computing the target function for the optimization problem 
dim = 2; % hardcoded for now
assert(size(points_in_set, 2) == dim);

syms x [1, dim]; % For dim-dimensions see original script by Amir
% B = [-0.5, 0; -0.2, 1]; % Box containing the set of points points_in_set
% B = [workspace(1,:); workspace(2,:)]; % Box containing the set of points points_in_set
B = [min(points_in_set(:, 1)), max(points_in_set(:, 1)); min(points_in_set(:, 2)), max(points_in_set(:, 2))];

[p_tmp, c] = multPoly(dim, x, args.deg);
f = intOverB(p_tmp, dim, x, B);

% Computing the coefficients of the polynomial p_tmp of the PSS
% representation using optimization by YALMIP and SEDUMI having only 1 SOS
% constraints, the rest of constraints are linear inequalities.

% points_in_set = [-1.0,  1.0;
%      -1.0, -1.0;
%       1.0, -1.0;
%       1.0,  1.0;
%      -1.0,  0.0;
%       1.0,  0.0;
%       0.0,  1.0;
%       0.0, -1.0];
% points_in_set = samples(labels == 1, :);
a = partSOSFitting(dim, x, p_tmp, c, f, B, points_in_set);

res = subs(p_tmp, c, a) - 1;
p = symfun(res, x);

% Plotting the 2d approximation
% figure;
% % fcontour(res, [-2,2,-2,2], 'LevelList', 0:0, 'MeshDensity', 1000, 'linewidth', 2, 'linecolor', 'red')
% fimplicit(res)
% hold on
% x_list = zeros(size(points_in_set, 1), 1);
% y_list = zeros(size(points_in_set, 1), 1);
% for i = 1:size(points_in_set, 1)
%      x_list(i) = points_in_set(i, 1);
%      y_list(i) = points_in_set(i, 2);
% end
% scatter(x_list, y_list, 40, [1, 0.5, 0], 'filled');
% axis equal;

end