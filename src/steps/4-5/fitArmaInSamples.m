function mdl = fitArmaInSamples(x, start, length, p, q)
%FITARMAINSAMPLES Summary of this function goes here
%   Detailed explanation goes here

% Get training dataset
x_train = x(start:start + length - 1);
mu_x = mean(x_train);
std_x = std(x_train);
x_train = x_train - mu_x;

% Get ARMA model
arma_model = get_arma_model(x_train, p, q);

% Create return argument
mdl = MyArmaModel(arma_model, mu_x, std_x, start, start + length - 1);

end

