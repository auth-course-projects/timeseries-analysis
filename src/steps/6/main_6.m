close('all'), clear, clc

%=====================
n0 = 400;
T_a = 6;
T_b = 6;
lambda_std_a = 1.5;
lambda_std_b = 1.5;
choice_a = 'a';
choice_b = 'c';
K_a = 16;
K_b = 13;
display = true;
%=====================


%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a']
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
    eval(['choice = choice_' ts_i ';']);
    eval(['K = K_' ts_i ';']);
    
    %% Find delay, \tau
    i_tau = mutualinformation(x_deseasoned, 10); % , [], ['X_' ts_i]);
    tau = find(islocalmin(i_tau(:, 2))) - 1;
    tau = tau(1);
    fprintf('\t- tau_%c = %d | ', ts_i, tau)
    
    %% Find embedding dimension, m
    mmax = 10;
    fnnM = falsenearest(x_deseasoned, tau, mmax); % , 10, 0, ['X_' ts_i]);
    m = find(fnnM(:, 2) <= 0.01);
    m = m(1);
    fprintf('m_%c = %d\n', ts_i, m)
    
    % Print scat.ter3
%     scatter3_(x_deseasoned, ts_i)
    
    % Print reconstructed state space points
    x_state_hat = embeddelays(x_deseasoned, m, tau);
    
    %% Compute Mean Change Points (MCPs)
%     display = false;
%     kes = zeros(40, 1);
%     i = 1;
%     for K = 1:40

        [mcps,~,e] = get_mcps_knn(ts_i, display, n0, T, choice, ...
                                  lambda_std, tau, m, K);
        fprintf('NRMSE = %.3f\n', e);
%         kes(i) = e;
%         i = i + 1;
%     end
%     
%     % Plot NRMSEs w.r.t. K (of KNN)
%     figure, clf, grid on, hold on
%     set(gca, 'FontName', 'JetBrains Mono')
%     set(gcf, 'Color', [1 1 1])    
%     plot(1:40, kes, 'o-', 'LineWidth', 2)
%     title(['NRMSE_' ts_i ' for Varying K of KNN (n_0=' num2str(n0) ', T=' num2str(T) '  -  m=' num2str(m) ', \tau=' num2str(tau) ')'], 'FontSize', 14, 'FontName', 'JetBrains Mono')
%     xlabel('K'), ylabel(['NRMSE_' ts_i '(K)'])
%     set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
%     hold off
    
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
end
