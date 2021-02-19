close('all'), clear, clc

maxtau = 30;

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
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
    
    %% Grid search on ARMA orders (p,q)
    if ~exist(['x' ts_i '_aics_fpes.mat'], 'file')
        aics = ones(11, 11);
        fpes = ones(11, 11);
        nrmses = ones(11, 11);
        for p = 0:10
            for q = 0:10
                if p==0 && q==0
                    continue;
                end

                % Fit ARMA (p,q) model on the detrended - stationary (since
                % no seasoning can be concluded from autocorrelations)
                % timeseries
                [nrmse_, ~, ~, ~, aic, fpe, ~] = ...
                    fitARMA(x_deseasoned, p, q, 1);
                aics(p + 1, q + 1) = aic;
                fpes(p + 1, q + 1) = fpe;
                nrmses(p + 1, q + 1) = nrmse_(1);
            end
        end
        
        % Save grid search results in a mat file (for speed)
        save(['x' ts_i '_aics_fpes.mat'], 'aics', 'fpes', 'nrmses')
    else
        load(['x' ts_i '_aics_fpes.mat'], 'aics', 'fpes', 'nrmses')
    end
    
    %% Compute optimal ARMA parameters
    % From AIC
    min_aic = min(aics(:));
    [p, q] = find(aics == min_aic);
    p_opt = p - 1;
    q_opt = q - 1;
    if ts_i == 'b'
        % In "B" timeseries the (9,9) is way too big, so we change them to 
        % smaller orders so as to avoid possible overfitting
%         p_opt = 5 - 1;
%         q_opt = 5 - 1;
    end
    fprintf('AIC: p_opt = %d, q_opt = %d --> ARIMA(%d,1,%d)\n', p_opt, ...
        q_opt, p_opt, q_opt)
    % From FPE
    min_fpe = min(fpes(:));
    [p, q] = find(fpes == min_fpe);
    fprintf('FPE: p_opt = %d, q_opt = %d --> ARIMA(%d,1,%d)\n', p-1, ...
        q-1, p-1, q-1)
%     % From NRMSE (1 step prediction)
%     min_nrmse = min(nrmses(:));
%     [p, q] = find(nrmses == min_nrmse);
%     fprintf('NRMSE: p_opt = %d, q_opt = %d --> ARIMA(%d,1,%d)\n', p-1, ...
%         q-1, p-1, q-1)

    %% Fit ARMA(p_opt, q_opt) and perform independence tests
    mu_x_deseasoned = mean(x_deseasoned);
    x_deseasoned_mmu = x_deseasoned - mu_x_deseasoned;
    arma_model_opt = get_arma_model(x_deseasoned_mmu, p_opt, q_opt);
    % Compute residuals
    x_deseasoned_hat = predict(arma_model_opt, x_deseasoned_mmu, 1) + ...
        mu_x_deseasoned;
    x_hat = x_deseasoned_hat + x_seasonal_component;
    x_res = x - x_hat;
    % Print residuals autocorrelation
    history_with_smoothing(x_res, 7, ['X_{' ts_i ',res}']);
    [r, hV] = autocorrelation_with_limits(x_res, 30, ...
        ['x_{' ts_i '_{res}} Autocorrelation Plot'], 0.05, true ...
    );
    % Check Portmanteau decisions
    if (~all(hV == 0))
        error(['Portmandeu test failed for lags ' ...
            char(join(string(find(hV == 1)), ','))])
    else
        disp(['Portmandeu test PASSED for all ' num2str(maxtau) ' lags!']);
    end
    
    % If only WN remained, print the fitting's NRMSE
    fprintf('NRMSE for 1-step-ahead prediction: %.4f\n', nrmse(x, x_hat));
    
    %% Check performance on initial timeseries
    y_hat = (x_hat + y_sqrt(1:end-1)).^2;
    figure, clf, grid on, hold on
    set(gca, 'FontName', 'JetBrains Mono')
    set(gcf, 'Color', [1 1 1])
    plot(y, '.-b')
    plot([y(1); y_hat], '.-r')
    title(['Y_' ts_i ' vs. Y_{' ts_i '_{hat}} Time History Plot'], 'FontSize', 14)
    set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
    hold off
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
end
