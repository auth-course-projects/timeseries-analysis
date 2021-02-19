function arma_model = get_arma_model(x, p, q)
%GET_ARMA_MODEL Remove mean and return an ARMA(p,q) model object.
% Remove mean from timeseries input
mu_x = mean(x);
x_dot = x - mu_x;
% Create ARMA(p,q) model and return
arma_model = armax(x_dot, [p q]);
end

