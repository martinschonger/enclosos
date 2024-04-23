function p = pss(points_in_set, args)

arguments
    points_in_set % points inside the semi-algebraic set
    args.deg = 4 % degree of the polynomial p_tmp of the PSS
end

% Computing the target function for the optimization problem 
dim = 2; % hardcoded for now
assert(size(points_in_set, 2) == dim);

syms x [1, dim]; % For dim-dimensions see original script by Amir
B = [min(points_in_set(:, 1)), max(points_in_set(:, 1)); min(points_in_set(:, 2)), max(points_in_set(:, 2))];

[p_tmp, c] = multPoly(dim, x, args.deg);
f = intOverB(p_tmp, dim, x, B);

a = partSOSFitting(dim, x, p_tmp, c, f, B, points_in_set);

res = subs(p_tmp, c, a) - 1;
p = symfun(res, x);

end
