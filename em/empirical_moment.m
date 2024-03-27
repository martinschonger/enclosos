clear;
clc;
close all

% Number of random points
num_points = 100;

% Generate random x-coordinates
P = [rand(num_points,1), rand(num_points,1)];

% Plot the random points
scatter(P(:,1), P(:,2));
xlabel('X');
ylabel('Y');
title('Random 2D Points');
hold on

% Empirical moment generation
x = sdpvar(1,1);
y = sdpvar(1,1);

degree = 2; % Polynomial degree
p = 2;      % Ambient dimension

v = monolist([x y], degree);
M = v*v';
Ms = 0;
for i=1:length(P)
    Mx = replace(M, x, P(i,1));
    Mxy = replace(Mx, y, P(i,2));
    Ms = Ms + Mxy;
end
Ms = (1/length(P))*Ms;

% Plot level curve
Delta = 0; % Tuning parameter
level = nchoosek(p + degree, degree);
Qd = v'*inv(Ms)*v - level - Delta; 
Qd_fun = yalmip2matlabFun('Qd');
fimplicit(Qd_fun)
