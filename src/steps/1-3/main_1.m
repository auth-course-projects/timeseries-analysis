close('all'), clear, clc

%% Get desired timeseries
% Fetch columns of the given Excel file (VideoViews.xlsx)
[y_a, y_b] = get_columns([3, 3+10]);
for ts_i = ['a', 'b']
    eval(['y = y_' ts_i ';']);
    
    % Plot history graph
    figure, clf
    plot(y, '.-'), title(['Y_' ts_i ' Time History Plot'])
    xlabel('t (day)'), ylabel(['Y_' ts_i '(t)']), grid on

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
    figure, clf
    plot(x, '.-'), title(['X_' ts_i ' (1st differences detrend) Time History Plot'])
    xlabel('t (day)'), ylabel(['X_' ts_i '(t)']), grid on
    
    % Plot autocorrelation & partial autocorrelation graphs of {X_t}
    r_x = autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (1st differences detrend) Autocorrelation Plot']);
    phi_x = partial_autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (1st differences detrend) Partial Autocorrelation Plot']);
    
    %% Detrend & stabilize trend-related variance
    % Stabilize variance (remove trend dependency) (Box & Cox transform)
    x = sqrt(y);    
    % Detrend using 1st order differences (d=1)
    x = x(2:end) - x(1:end-1);
    
    % Plot history graph of {X_t}
    figure, clf, grid on
    plot(x, '.-'), title(['X_' ts_i ' (sqrt of 1st differences detrend) Time History Plot'])
    xlabel('t (day)'), ylabel(['X_' ts_i '(t)'])
    
    % Plot autocorrelation & partial autocorrelation graphs of {X_t}
    r_x = autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (sqrt of 1st differences detrend) Autocorrelation Plot']);
    phi_x = partial_autocorrelation_with_limits(x, max_lag, ['X_' ts_i ' (sqrt of 1st differences detrend) Partial Autocorrelation Plot']);
    
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
    
end
