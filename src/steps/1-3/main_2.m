close('all'), clear, clc

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
    eval(['y = y_' ts_i ';']);
    
    % Get detrended timeseries from main_1.m
    x = sqrt(y(2:end)) - sqrt(y(1:end-1));    
    
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

                % Fit ARMA (p,q) model on the detrended - stationary (since no
                % seasoning can be concluded from autocorrelations) -
                % timeseries
                [nrmse, ~, ~, ~, aic, fpe, ~] = ...
                    fitARMA(x, p, q, max(p,q));
                aics(p + 1, q + 1) = aic;
                fpes(p + 1, q + 1) = fpe;
                nrmses(p + 1, q + 1) = nrmse(1);
            end
        end
        
        % Save grid search results in a mat file (for speed)
        save(['x' ts_i '_aics_fpes.mat'], 'aics', 'fpes')
    else
        load(['x' ts_i '_aics_fpes.mat'], 'aics', 'fpes')
    end
    
    %% Compute optimal ARMA parameters
    % From AIC
    min_aic = min(aics(:));
    [p, q] = find(aics == min_aic);
    [p - 1, q - 1]
    % From FPE
    min_fpe = min(fpes(:));
    [p, q] = find(fpes == min_fpe);
    [p - 1, q - 1]
    
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
    
end
