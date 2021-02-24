function s_y = history_with_smoothing(y, ma_order, ts_name)
%HISTORY_WITH_SMOOTHING Summary of this function goes here
% INPUTS 
% - y        : vector of length 'n' of the time series
% - ma_order : the maorder of the moving average filter
% - ts_name  : the name of the timeseries (appears in ylabel & title)
% OUTPUTS
% - s_y      : vector of length 'n' of the smoothed time series
figure, clf, grid on, hold on
set(gca, 'FontName', 'JetBrains Mono')
set(gcf, 'Color', [1 1 1])

% Plot MA-smoothed timeseries
plot(movingaveragesmooth(y, ma_order), '-c', 'linewidth', 2.5)

% Plot initial timeseries
plot(y, '.-'), xlabel('t (day)'), ylabel([ts_name '(t)'])

title([ts_name ' Time History Plot'], 'FontSize', 14)
set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
% hold off
end