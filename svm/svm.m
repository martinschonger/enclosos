% Copyright © 2024 Martin Schonger
% This software is licensed under the GPLv3.


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

SVMModel = fitcsvm(samples, labels, 'kernelfunction', 'polynomial', 'polynomialorder', args.deg, 'BoxConstraint', args.boxconstraint, 'kernelscale', args.kernelscale, 'weights', weights);

x = vpa(sym('x', [dim; 1], 'real'), args.precision);
polydeg = SVMModel.KernelParameters.Order;
supvecs = SVMModel.SupportVectors';
labels2 = SVMModel.SupportVectorLabels';
alphas = SVMModel.Alpha';
bias = SVMModel.Bias;
dotprods = sum(supvecs .* x / (SVMModel.KernelParameters.Scale^2), 1);
grammat = power(1 + dotprods, polydeg);
tmpprod = alphas .* labels2 .* grammat;

res = sum(tmpprod) + bias;
p = symfun(res, x);

end
