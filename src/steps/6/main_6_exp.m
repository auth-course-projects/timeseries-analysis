close('all'), clear, clc

%=====================
n0 = 400;
K_a = 16;
K_b = 13;
choice = 'c';
Ts = 1:10;
lambda_stds = 1.1:0.1:2;
%=====================

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
    eval(['y = y_' ts_i ';']);
    eval(['K = K_' ts_i ';']);
    
    %% Setup Experiment
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

    % Find delay, \tau
    i_tau = mutualinformation(x_deseasoned, 20);
    tau = find(islocalmin(i_tau(:, 2))) - 1;
    tau = tau(1);
    fprintf('\t- tau_%c = %d | ', ts_i, tau)

    % Find embedding dimension
    mmax = 10;
    fnnM = falsenearest(x_deseasoned, 2, mmax);
    m = find(fnnM(:, 2) <= 0.01);
    m = m(1);
    fprintf('m_%c = %d\n', ts_i, m)
    
    %% Run experiment
    if (~exist(['exp6_' ts_i '.mat'], 'file'))
        % Allocate variables
        exp6_mcps = zeros(length(Ts), length(lambda_stds), 100);
        exp6_mcps_count = zeros(length(Ts), length(lambda_stds));
        exp6_ets = zeros(length(Ts), length(lambda_stds));
        exp6_nrmses = zeros(length(Ts), length(lambda_stds));
        
        % Grid-search looop
        for Ts_i = 1:length(Ts)
            T = Ts(Ts_i);

            for lambda_stds_i = 1:length(lambda_stds)
                lambda_std = lambda_stds(lambda_stds_i);

                % Compute Mean Change Points (MCPs)
                [mcps,et,e] = get_mcps_knn(ts_i, false, n0, T, choice, ...
                                           lambda_std, tau, m, K);

                % Assign MCPs and Elapsed Time (ET)
                if (~isempty(mcps))
                    l = length(mcps);
                    exp6_mcps(Ts_i, lambda_stds_i, 1:l) = mcps;
                    exp6_mcps_count(Ts_i, lambda_stds_i) = l;
                end
                exp6_ets(Ts_i, lambda_stds_i) = et;
                exp6_nrmses(Ts_i, lambda_stds_i) = e;
            end
        end

        % Save experiment results for respective timeseries
        eval(['exp6_mcps_' ts_i ' = exp6_mcps;']);
        eval(['exp6_mcps_count_' ts_i ' = exp6_mcps_count;']);
        eval(['exp6_ets_' ts_i ' = exp6_ets;']);
        eval(['exp6_nrmses_' ts_i ' = exp6_nrmses;']);
        save(['exp6_' ts_i '.mat'], ['exp6_mcps_' ts_i], ...
            ['exp6_mcps_count_' ts_i], ['exp6_ets_' ts_i], ...
            ['exp6_nrmses_' ts_i]);
    else
        load(['exp6_' ts_i '.mat'], ['exp6_mcps_' ts_i], ...
            ['exp6_mcps_count_' ts_i], ['exp6_ets_' ts_i], ...
            ['exp6_nrmses_' ts_i]);
        eval(['exp6_mcps = exp6_mcps_' ts_i ';']);
        eval(['exp6_mcps_count = exp6_mcps_count_' ts_i ';']);
        eval(['exp6_ets = exp6_ets_' ts_i ';']);
        eval(['exp6_nrmses = exp6_nrmses_' ts_i ';']);
    end
    
    
    %% Plots
    % MCP(T, lambda_std)
    figure, clf, grid on, hold on
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])
    [X, Y] = meshgrid(Ts, lambda_stds);
    surf(X, Y, exp6_mcps_count)
    title(['Number of Mean-Change Points for Non-Linear (varying T, lambda_{std} - m=' num2str(m) ', \tau=' num2str(tau) ')'], ...
        'FontSize', 14, 'FontName', 'JetBrains Mono')
    xlabel('T'), ylabel('lambda_{std}'), zlabel(['|MCP_' ts_i '|'])
    hold off
    set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
    
    % NRMSE(T, lambda_std)
    figure, clf, grid on, hold on
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])
    [X, Y] = meshgrid(Ts, lambda_stds);
    surf(X, Y, exp6_nrmses)
    title(['NRMSE for Non-Linear (varying T, lambda_{std} - m=' num2str(m) ', \tau=' num2str(tau) ')'], ...
        'FontSize', 14, 'FontName', 'JetBrains Mono')
    xlabel('T'), ylabel('lambda_{std}'), zlabel(['NRMSE_' ts_i])
    hold off
    set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])

    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end

end
