close('all'), clear, clc

%=====================
n0 = 400;
choice = 'c';
Ts = 1:10;
lambda_stds = 1.1:0.1:2;
%=====================

for ts_i = ['a', 'b']
    
    if (~exist(['exp_' ts_i '.mat'], 'file'))
        % Setup experiment
        exp_mcps = zeros(length(Ts), length(lambda_stds), 100);
        exp_mcps_count = zeros(length(Ts), length(lambda_stds));
        exp_ets = zeros(length(Ts), length(lambda_stds));
        exp_nrmses = zeros(length(Ts), length(lambda_stds));

        % Run experiment
        for Ts_i = 1:length(Ts)
            T = Ts(Ts_i);
            
            for lambda_stds_i = 1:length(lambda_stds)
                lambda_std = lambda_stds(lambda_stds_i);

                % Compute Mean Change Points (MCPs)
                [mcps,et,e] = get_mcps(ts_i, false, n0, T, choice, ...
                                       lambda_std);

                % Assign MCPs and Elapsed Time (ET)
                if (~isempty(mcps))
                    l = length(mcps);
                    exp_mcps(Ts_i, lambda_stds_i, 1:l) = mcps;
                    exp_mcps_count(Ts_i, lambda_stds_i) = l;
                end
                exp_ets(Ts_i, lambda_stds_i) = et;
                exp_nrmses(Ts_i, lambda_stds_i) = e;
            end
            
        end

        % Save experiment results for respective timeseries
        eval(['exp_mcps_' ts_i ' = exp_mcps;']);
        eval(['exp_mcps_count_' ts_i ' = exp_mcps_count;']);
        eval(['exp_ets_' ts_i ' = exp_ets;']);
        eval(['exp_nrmses_' ts_i ' = exp_nrmses;']);
        save(['exp_' ts_i '.mat'], ['exp_mcps_' ts_i], ...
            ['exp_mcps_count_' ts_i], ['exp_ets_' ts_i], ...
            ['exp_nrmses_' ts_i]);
    else
        load(['exp_' ts_i '.mat'], ['exp_mcps_' ts_i], ...
            ['exp_mcps_count_' ts_i], ['exp_ets_' ts_i], ...
            ['exp_nrmses_' ts_i]);
        eval(['exp_mcps = exp_mcps_' ts_i ';']);
        eval(['exp_mcps_count = exp_mcps_count_' ts_i ';']);
        eval(['exp_ets = exp_ets_' ts_i ';']);
        eval(['exp_nrmses = exp_nrmses_' ts_i ';']);
    end
    
    %% Plots
    % MCP(T, lambda_std)
    figure, clf, grid on, hold on
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])
    [X, Y] = meshgrid(Ts, lambda_stds);
    surf(X, Y, exp_mcps_count)
    title('Number of Mean-Change Points (varying T, lambda_{std})', ...
        'FontSize', 14, 'FontName', 'JetBrains Mono')
    xlabel('T'), ylabel('lambda_{std}'), zlabel(['|MCP_' ts_i '|'])
    hold off
    set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
    
    % NRMSE(T, lambda_std)
    figure, clf, grid on, hold on
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])
    [X, Y] = meshgrid(Ts, lambda_stds);
    surf(X, Y, exp_nrmses)
    title('NRMSE (varying T, lambda_{std})', ...
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

