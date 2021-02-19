close('all'), clear, clc

%=====================
T_a = 5;
T_b = 5;
choice_a = 'c';
choice_b = 'c';
lambda_std_a = 1.5;
lambda_std_b = sqrt(2);
display = true;
%=====================

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);

mcps_len = zeros(21, 1);
mcps_len_i = 0;
display = false;

for lambda_std_b = 1:0.05:2
    mcps_len_i = mcps_len_i + 1;
    
    for ts_i = ['b']    
        % Set timeseries and hyperparameters
        eval(['y = y_' ts_i ';']);
        eval(['T = T_' ts_i ';']);
        eval(['choice = choice_' ts_i ';']);
        eval(['lambda_std = lambda_std_' ts_i ';']);

        if (display == true)
            disp(['Computing for timeseries "' num2str(ts_i) '" (T=' ...
                num2str(T) ', choice="' num2str(choice) '", lambda_std=' ...
                num2str(lambda_std) ')'])
        end

        % Get detrended timeseries from main_1.m
        y_sqrt = sqrt(y);
        x = y_sqrt(2:end) - y_sqrt(1:end-1);

        % Remove seasonal component
        if (ts_i == 'b')
            % Calculate seasonal component for TimeSeries "B"
            x_seasonal_component = seasonalcomponents(x, 14);
        else
            x_seasonal_component = zeros(length(x), 1);
        end
        % Deseason Timeseries
        x_deseasoned = x - x_seasonal_component;

        %% Get ARMA models (from previous steps)
        % Optimal Orders
        if (ts_i == 'a')
            p_opt = 0;
            q_opt = 1;
        else
            p_opt = 4;
            q_opt = 4;
        end
    %     % ARMA Model (fitted in the entire timeseries)
    %     mu_x_deseasoned = mean(x_deseasoned);
    %     x_deseasoned_mmu = x_deseasoned - mu_x_deseasoned;
    %     arma_model_opt = get_arma_model(x_deseasoned_mmu, p_opt, q_opt);

        %% Compute Mean Change Points (MCPs)
        mcps = zeros(length(x), 1);
        % 1) Fit model on the first 400 samples
        n0 = 400;
        mdl = fitArmaInSamples(x_deseasoned, 1, n0, p_opt, q_opt);
        % 2) Define criterion
        alpha = lambda_std * mdl.StdX;
        % 3) Check criterion in loop
        N = length(x);

        s = zeros(N - n0 - T, 1);
        update_model = false;
        n = n0;
        while (n <= (N-T))
            % - Predict next T values
            x_n_of_k = predictStepsAhead(x_deseasoned, mdl, T, n, n0);
            % - Compute S_n
            s(n - n0 + 1) = mean(abs(x_deseasoned(n+1:(n + T)) - x_n_of_k));
            % - Compare with criterion
            if (s(n - n0 +1) >= alpha)
                if (display == true)
                    disp(['MCP Found (n = ' num2str(n) ')'])
                end
                mcps(n) = 1;
                n = n + T;

                if choice == 'c' || choice == 'b'
                   update_model = true; 
                end
            else
                n = n + 1;

                if choice == 'b'
                   update_model = true; 
                end
            end

            % If choice is 'b', refit model
            if (update_model == true)
                % 1) Fit model on the last 400 samples
                mdl = fitArmaInSamples(x_deseasoned, n-n0+1, n0, p_opt, q_opt);
                % 2) Define criterion
                alpha = lambda_std * mdl.StdX;

                update_model = false;
            end
        end

        mcps_len(mcps_len_i) = length(find(mcps == 1));
        continue;

        %% Plots
        % Plot criterion and MCPs on stationary timeseries
        figure, clf, grid on, hold on
        plot(n0:length(x)-T, s, '.-k')
        for i = find(mcps == 1)
            line([i i], ylim, 'LineWidth', 1.5, 'Color', 'cyan')
        end
        hold off

        % and on initial timeseries
        figure, clf, grid on, hold on
        plot(1:length(y), y, '.-')
        for i = find(mcps == 1)
            line([i i], ylim, 'LineWidth', 2.5, 'Color', 'cyan')
        end
        hold off


        if ts_i == 'a'
            c = input('Continue with Y_b? Y/N [Y]:', 's');
            if ~(isempty(c) || c == 'y' || c == 'Y')
                disp('OK, Breaking...')
                break;
            end
        end
    end

end

plot(1:0.05:2, mcps_len, 'o-', 'LineWidth', 2.0)
