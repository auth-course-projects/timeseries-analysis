close('all'), clear, clc

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
    eval(['y = y_' ts_i ';']);
    
    % Plot history graph + MA(7)-smoothing trend line
    history_with_smoothing(y, 7, ['Y_' ts_i])

    %% Get initial (sample) autocorrelations
    max_lag = 30;
    % Plot autocorrelation graph for a maximum lag of 30
    r_y = autocorrelation_with_limits(y, max_lag, ['Y_' ts_i ' Autocorrelation Plot']);
    % Plot partial autocorrelation graph
    phi_y = partial_autocorrelation_with_limits(y, max_lag, ['Y_' ts_i ' Partial Autocorrelation Plot']);
    % Both timeseries show storng auto-correlations. Detrending follows.
    
    %% Detrend: 1st-differences detrending
    x = y(2:end) - y(1:end-1);
    
    % Plot history graph of {X_t}
    history_with_smoothing(x, 7, ['BY_' ts_i])
    
    % Plot autocorrelation & partial autocorrelation graphs of {X_t}
    autocorrelation_with_limits(x, max_lag, ['BY_' ts_i ' (1st differences detrend) Autocorrelation Plot']);
    partial_autocorrelation_with_limits(x, max_lag, ['BY_' ts_i ' (1st differences detrend) Partial Autocorrelation Plot']);
    
    %% Detrend & stabilize trend-related variance
    % Stabilize variance (remove trend dependency) (Box & Cox transform)
    y_sqrt = sqrt(y);
    history_with_smoothing(y_sqrt, 7, ['sqrt(Y_' ts_i ')'])

    % Detrend using 1st order differences (d=1)
    x = y_sqrt(2:end) - y_sqrt(1:end-1);
    if ts_i == 'a'
        mu_x = mean(x);
        fprintf('Removing mean of X_%c, mu = %.4f\n', ts_i, mu_x);
        x = x - mu_x;
    end
    
    % Plot history graph of {X_t}
    history_with_smoothing(x, 7, ['X_' ts_i])
    
    % Plot autocorrelation & partial autocorrelation graphs of {X_t}
    autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (sqrt(Y_' ts_i ') + 1st differences detrend) Autocorrelation Plot']);
    partial_autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (sqrt(Y_' ts_i ') + 1st differences detrend) Partial Autocorrelation Plot']);
    
    %% Remove seasonal components
    if ts_i == 'b'
        % Calculate seasonal component
        x_seasonal_component = seasonalcomponents(x, 14);
        % Plot
        figure, clf, grid on, hold on
        set(gca, 'FontName', 'JetBrains Mono')
        set(gcf, 'Color', [1 1 1])
        plot(x_seasonal_component(1:14), '.-'), xlabel('t (day)'), ylabel(['seasonal\_component(X_b)(t)'])
        title(['X_b Seasonal Component (N = 14 days)'], 'FontSize', 14)
        set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
        % Deseason Timeseries
        fprintf('Removing seasonality of X_%c, N = %d\n', ts_i, 14);
        x = x - x_seasonal_component;
        % Zero-mean Timeseries
        mu_x = mean(x);
        fprintf('Removing mean of X_%c, mu = %.4f\n', ts_i, mu_x);
        x = x - mu_x;
        % Plot history, autocorrelation & partial autocorrelation
        history_with_smoothing(x, 7, ['X_{' ts_i '_{deseasoned}}'])
        autocorrelation_with_limits(x, max_lag, ['X_{' ts_i '_{deseasoned}} (sqrt(Y_' ts_i ') + 1st differences detrend + deseason) Autocorrelation Plot']);
        partial_autocorrelation_with_limits(x, max_lag, ['X_{' ts_i '_{deseasoned}} (sqrt(Y_' ts_i ') + 1st differences detrend + deseason) Partial Autocorrelation Plot']);
    end
    
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
end

