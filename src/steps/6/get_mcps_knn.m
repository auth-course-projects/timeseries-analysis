function [mcps, et, e] = get_mcps_knn(ts_i, display, n0, T, choice, ...
                                      lambda_std, tau, m, K)
%GET_MCPS Summary of this function goes here
%   Detailed explanation goes here


%% Get stationary timeseries
persistent y_a y_b x_a_deseasoned x_b_deseasoned
if (isempty(y_a) || isempty(y_b) || isempty(x_a_deseasoned) || ...
        isempty(x_b_deseasoned))
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
end

eval(['y = y_' ts_i ';']);
eval(['x_deseasoned = x_' ts_i '_deseasoned;']);


%% Set default hyperparameters
persistent default_n0 default_T default_choice default_lambda_std ...
           default_tau default_m default_K 
if (isempty(default_n0))
    default_n0 = 400;
    default_T = 5;
    default_lambda_std = sqrt(2);
    default_tau = 1;
    default_m = 3;
    default_K = 3;
    default_choice = 'c';
end

if (nargin < 3)
    n0 = default_n0;
    T = default_T;
    choice = default_choice;
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 4)
    T = default_T;
    choice = default_choice;
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 5)
    choice = default_choice;
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 6)
    lambda_std = default_lambda_std;
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 7)
    tau = default_tau;
    m = default_m;
    K = default_K;
elseif (nargin < 8)
    m = default_m;
    K = default_K;
elseif (nargin < 9)
    K = default_K;
end


disp(['Computing KNN for timeseries "' num2str(ts_i) '" (T=' num2str(T) ...
    ', lambda_std=' num2str(lambda_std) ', choice="' choice '", tau=' ...
    num2str(tau) ', m=' num2str(m) ', K=' num2str(K) ')'])

start_time = tic;


%% Get local neighboors (non-linear model)
% TODO



%% Compute Mean Change Points (MCPs)
N = length(x_deseasoned);
mcps = zeros(N, 1);
% 1) Define criterion
alpha = lambda_std * std(x_deseasoned(1:n0));
alpha_cps = zeros(100, 2);
alpha_cps_i = 1;
alpha_cps(alpha_cps_i, :) = [n0, alpha];
% 3) Check criterion in loop
s = NaN * zeros(N - n0 - T, 1);
x_hat = zeros(N, 1);
x_hat(1:n0) = x_deseasoned(1:n0);
n = n0;
while (n <= (N-T))    
    % - Predict next T values
    x_n_of_k = localpredictmultistep(x_deseasoned((n+1-n0):(n+T)), n0, ...
                                     tau, m, T, K);
    x_hat(n+1:(n + T)) = x_n_of_k;
    % - Compute S_n
    s(n - n0 + 1) = mean(abs(x_deseasoned(n+1:(n + T)) - x_n_of_k));
    % - Compare with criterion
    if (s(n - n0 +1) >= alpha)
        n = n + T;
        
        if (display == true)
            fprintf('\t--> MCP Found (n = %04d)\n', n)
        end
        mcps(n) = 1;

        if choice == 'c' || choice == 'b'
           update_model = true; 
        end
    else
        n = n + 1;
        update_model = (choice == 'b');
    end

    % If choice is 'b' or (choice is 'c' and MCP found), refit model
    if (update_model == true)
        % 1) Fit model on the last 400 samples
        % NOT APPLICABLE TO NON-LINEAR
        std_ = std(x_deseasoned(n-n0+1:n));
        % 2) Define criterion
        alpha = lambda_std * std_;
        % 3) Push new criterion for display
        if (display)
            alpha_cps_i = alpha_cps_i + 1;
            alpha_cps(alpha_cps_i, :) = [n, alpha];
        end

        update_model = false;
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
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])    
    % - plot S_n
    end_ = length(x_deseasoned)-T;
    plot(n0:end_, s, '.-')
    % - plot alpha limits
    alpha_cps_i = alpha_cps_i + 1;
    alpha_cps(alpha_cps_i, :) = [n, alpha];
    for i = 1:alpha_cps_i - 1
        plot([alpha_cps(i, 1) alpha_cps(i + 1, 1)], ...
            alpha_cps(i, 2)*[1 1], '--c', 'LineWidth', 1.5)
    end
    % - plot MCPs
    for i = mcps
        line([i i], ylim, 'Color', 'black', 'LineWidth', 2)
    end
    title(['S_' ts_i ' Statistic Measure for Non-Linear (n_0=' ...
        num2str(n0) ', T=' num2str(T) ', lambda_{std}=' ...
        num2str(lambda_std) ', choice="' choice '"  -  m=' num2str(m) ...
        ', \tau=' num2str(tau) ', K=' num2str(K) ')'], ...
        'FontSize', 14, 'FontName', 'JetBrains Mono')
    xlabel('n'), ylabel(['S_' ts_i '(n)'])
    set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
    hold off

    % and on initial timeseries
    history_with_smoothing(y, 7, ['y_' ts_i '']);
    for i = mcps
        line([i i], ylim, 'Color', 'black', 'LineWidth', 2)
    end
    title(['Y_' ts_i ' Mean Change Points (MCPs) for Non-Linear (n_0=' ...
        num2str(n0) ', T=' num2str(T) ', lambda_{std}=' ...
        num2str(lambda_std) ', choice="' choice '"  -  m=' num2str(m) ...
        ', \tau=' num2str(tau) ', K=' num2str(K) ')'], ...
        'FontSize', 14, 'FontName', 'JetBrains Mono')
    hold off
end

end

