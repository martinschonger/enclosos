function p = em(samples, args)

arguments
    samples
    args.deg = 2 % Polynomial degree
    args.ambi_dim = 2 % Ambient dimension
    args.delta = 0 % Tuning parameter
end

% Empirical moment generation
x = sdpvar(1,1);
y = sdpvar(1,1);

v = monolist([x y], args.deg);
M = v*v';
Ms = 0;
for i=1:length(samples)
    Mx = replace(M, x, samples(i,1));
    Mxy = replace(Mx, y, samples(i,2));
    Ms = Ms + Mxy;
end
Ms = (1/length(samples))*Ms;

% Plot level curve
level = nchoosek(args.ambi_dim + args.deg, args.deg);
Qd = v'*inv(Ms)*v - level - args.delta; 
Qd_fun = yalmip2matlabFun('Qd');
% fimplicit(Qd_fun)

x = vpa(sym('x', [2; 1], 'real'), 16);
res = Qd_fun(x(1), x(2));
p = symfun(res, x);

end