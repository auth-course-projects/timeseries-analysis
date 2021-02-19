function preds = predictStepsAhead(x, mdl, T, n, n0)
%PREDICTSTEPSAHEAD Summary of this function goes here
%   Detailed explanation goes here

% Get training data
% lims = [n0, n]
x_train = x((n+1-n0):n);

% Zero-mean training data
mu_x_train = mean(x_train);
x_train_mmu = x_train - mu_x_train;

% Predict T steps ahead based on training data
preds = mu_x_train + forecast( ...
    mdl.ArmaModel, x_train_mmu, T ...
);

end
