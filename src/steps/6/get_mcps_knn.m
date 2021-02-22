function [mcps, et, e] = get_mcps_knn(ts_i, display, n0, T, lambda_std, ...
    tau, m, K)
%GET_MCPS Summary of this function goes here
%   Detailed explanation goes here


%% Get stationary timeseries
persistent y_a y_b x_a_deseasoned x_b_deseasoned x_a_deseasoned_std ...
    x_b_deseasoned_std
if (isempty(y_a) || isempty(y_b) || isempty(x_a_deseasoned) || ...
        isempty(x_b_deseasoned) || isempty(x_a_deseasoned_std) || ...
        isempty(x_b_deseasoned_std))
    % Fetch columns of the given Excel file (VideoViews.xlsx)
    [y_a, y_b] = get_columns([3, 3+10]);    
    
    % Get detrended timeseries from main_1.m
    y_a_sqrt = sqrt(y_a);
    x_a = y_a_sqrt(2:end) - y_a_sqrt(1:end-1);
    y_b_sqrt = sqrt(y_b);
    x_b = y_b_sqrt(2:end) - y_b_sqrt(1:end-1);

    % Deseason Timeseries
    x_a_deseasoned = x_a;
    x_b_deseasoned = x_b - seasonalcomponents(x_b, 14);
    
    % Calculate Standard Deviation
    x_a_deseasoned_std = std(x_a_deseasoned);
    x_b_deseasoned_std = std(x_b_deseasoned);
end

eval(['y = y_' ts_i ';']);
eval(['x_deseasoned = x_' ts_i '_deseasoned;']);
eval(['x_deseasoned_std = x_' ts_i '_deseasoned_std;']);


%% Set default hyperparameters
persistent default_n0 default_T default_lambda_std default_tau ...
    default_m default_K
if (isempty(default_n0))
    default_n0 = 400;
    default_T = 5;
    default_lambda_std = sqrt(2);
    default_tau = 1;
    default_m = 3;
    default_K = 3;
end

if (nargin < 3)
    n0 = default_n0;
    T = default_T;
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 4)
    T = default_T;
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 5)
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 6)
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 7)
    m = default_m;
    K = default_K;
elseif (nargin < 8)
    K = default_K;
end


disp(['Computing KNN for timeseries "' num2str(ts_i) '" (T=' num2str(T) ...
    ', lambda_std=' num2str(lambda_std) ', tau=' num2str(tau) ...
    ', m=' num2str(m) ', K=' num2str(K) ')'])

start_time = tic;


%% Get local neighboors (non-linear model)
% TODO



%% Compute Mean Change Points (MCPs)
N = length(x_deseasoned);
mcps = zeros(N, 1);
% 1) Define criterion
alpha = lambda_std * x_deseasoned_std;
% 2) Check criterion in loop
s = zeros(N - n0 - T, 1);
x_hat = zeros(N, 1);
x_hat(1:n0) = x_deseasoned(1:n0);
n = n0;
while (n <= (N-T))
    % - Predict next T values
    x_n_of_k = localpredictmultistep(x_deseasoned((n+1-n0):end), n0, tau, ...
        m, T, K);
    x_hat(n+1:(n + T)) = x_n_of_k;
    % - Compute S_n
    s(n - n0 + 1) = mean(abs(x_deseasoned(n+1:(n + T)) - x_n_of_k));
    % - Compare with criterion
    if (s(n - n0 +1) >= alpha)
        if (display == true)
            fprintf('\t--> MCP Found (n = %04d)\n', n)
        end
        mcps(n) = 1;
        n = n + T;
    else
        n = n + 1;
    end
end

et = toc(start_time);
if (display == true)
    fprintf('\tSeconds Elapsed: %.3f\n', et)
end

% Set as MCP the non-zero values only
mcps = find(mcps == 1);

% Compute NRMSE
e = nrmse(x_deseasoned((n0+1):end), x_hat(n0+1:end));


%% Plots
if (display)
    % Plot criterion and MCPs on stationary timeseries
    figure, clf, grid on, hold on
    plot(n0:N-T, s, '.-k')
    for i = mcps
        line([i i], ylim, 'LineWidth', 1.5, 'Color', 'cyan')
    end
    hold off

    % and on initial timeseries
    figure, clf, grid on, hold on
    plot(1:length(y), y, '.-')
    for i = mcps
        line([i i], ylim, 'LineWidth', 2.5, 'Color', 'cyan')
    end
    hold off
end

end

