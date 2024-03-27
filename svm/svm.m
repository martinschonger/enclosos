function p = svm(samples, labels, weights, args)

arguments
    samples
    labels
    weights
    args.deg = 4
    args.boxconstraint = 1600
    args.kernelscale = 0.48
    args.precision = 16
end

dim = 2; % hardcoded for now

% SVMModel = fitcsvm(samples, labels)
% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 4, 'BoxConstraint', 100, 'weights', weights, 'OptimizeHyperparameters', 'auto')
% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 4, 'standardize', true, 'weights', weights) % might work well, but could not get the reconstruction working
% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 3, 'BoxConstraint', 100000, 'kernelscale', 1/3, 'weights', weights)
% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 4, 'BoxConstraint', 10000, 'weights', weights)  % working for robot obstacles

% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 4, 'BoxConstraint', 50000, 'weights', weights)
SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', args.deg, 'BoxConstraint', args.boxconstraint, 'kernelscale', args.kernelscale, 'weights', weights)
% SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', 4, 'BoxConstraint', 100000, 'weights', weights)

classOrder = SVMModel.ClassNames;

% sv = SVMModel.SupportVectors;
is_sv = SVMModel.IsSupportVector;
sv = reshape(samples(repmat(is_sv, 1, dim)), length(SVMModel.Alpha), dim);

% figure;
% gscatter(samples(:,1), samples(:,2), labels);
% hold on;
% plot(sv(:,1), sv(:,2), 'ko', 'MarkerSize', 10);
% axis equal;
% legend('outside', 'unsafe', 'Support Vector');
% xlim([limits((dim1 - 1)*2+1), limits((dim1 - 1)*2+2)]);
% ylim([limits((dim2 - 1)*2+1), limits((dim2 - 1)*2+2)]);
% plot(sv(:,1), sv(:,2), 'ko', 'MarkerSize', 10, 'displayname', 'support vector');

% scatter(sv(:,1), sv(:,2), 300, 'black', 'displayname', 'support vector');

% eval_point = [0.15; 0.4];
% [~, score] = predict(SVMModel, eval_point')
% 
% eval_point = [-0.15; -0.2];
% [~, score] = predict(SVMModel, eval_point')
% 
% eval_point = [-0.4; -0.6];
% [~, score] = predict(SVMModel, eval_point')

% dim = 2;
% tmp_point = eval_point;
x = vpa(sym('x', [dim; 1], 'real'), args.precision);
polydeg = SVMModel.KernelParameters.Order;
% supvecs = reshape(samples(repmat(SVMModel.IsSupportVector, 1, dim)), length(SVMModel.Alpha), dim).';
supvecs = SVMModel.SupportVectors';
% supvecs = sv.';
labels2 = SVMModel.SupportVectorLabels';
alphas = SVMModel.Alpha';
bias = SVMModel.Bias;
dotprods = sum(supvecs .* x / (SVMModel.KernelParameters.Scale^2), 1);
grammat = power(1 + dotprods, polydeg);
tmpprod = alphas .* labels2 .* grammat;

res = sum(tmpprod) + bias;
p = symfun(res, x);
% [C, T] = coeffs(res)

% oldFolder = cd('C:\Users\martin\dev\ds\');
% [sdpexpr_tmp, sdpvars_tmp] = abcds.util.sym_to_sdpvar(res);
% [C2, T2] = coefficients(sdpexpr_tmp)
% 
% tmpfun = abcds.util.sdpvar_to_fun(sdpexpr_tmp, sdpvars_tmp.x);
% cd(oldFolder);

% figure;
% % fcontour(res, [3, 7, 1, 2.5], 'LevelList', 0:0)
% % fcontour(res, [-3, 6, -2, 2], 'LevelList', 0:0)
% % rd.plotLines;
% hold on;
% fcontour(res, [-5, 5, -5, 5], 'LevelList', 0:0, 'MeshDensity', 1000);
% axis equal;

% fcontour(res, limits, 'LevelList', 0:0, 'MeshDensity', 1000, 'linewidth', 2, 'linecolor', 'red');

end