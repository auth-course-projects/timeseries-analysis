close('all'), clear, clc

%=====================
n0 = 400;
T_a = 5;
T_b = 5;
lambda_std_a = 1.5;
lambda_std_b = sqrt(2);
K_a = 11;
K_b = 11;
display = true;
%=====================


%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
    %% Set timeseries
    eval(['y = y_' ts_i ';']);
    
    % Get detrended timeseries from main_1.m
    y_sqrt = sqrt(y);
    x = y_sqrt(2:end) - y_sqrt(1:end-1);
    
    % Remove seasonal component
    if ts_i == 'b'
        % Calculate seasonal component
        x_seasonal_component = seasonalcomponents(x, 14);
    else
        x_seasonal_component = zeros(length(x), 1);
    end
    % Deseason Timeseries
    x_deseasoned = x - x_seasonal_component;
    
    %% Set hyperparameters
    eval(['T = T_' ts_i ';']);
    eval(['lambda_std = lambda_std_' ts_i ';']);
    eval(['K = K_' ts_i ';']);
    
    %% Find delay, \tau
    i_tau = mutualinformation(x_deseasoned, 10);
    tau = find(islocalmin(i_tau(:, 2))) - 1;
    tau = tau(1);
    fprintf('\t- tau_%c = %d | ', ts_i, tau)
    
    %% Find embedding dimension, m
    mmax = 10;
    fnnM = falsenearest(x_deseasoned(1:400), 2, mmax);
    m = find(fnnM(:, 2) <= 0.01);
    m = m(1);
    fprintf('m_%c = %d\n', ts_i, m)
    
    %% Compute Mean Change Points (MCPs)
    display = false;
    kes = zeros(20, 1);
    i = 1;
    for K = 1:2:40
        [mcps,~,e] = get_mcps_knn(ts_i, display, n0, T, lambda_std, tau, m, K);
%         fprintf('NRMSE = %.3f\n', e);
        kes(i) = e;
        i = i + 1;
    end
    figure, clf, grid on
    plot(1:2:40, kes, 'o-', 'LineWidth', 2)
    
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
end
