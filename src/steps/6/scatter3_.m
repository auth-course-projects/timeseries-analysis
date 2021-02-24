function scatter3_(x, ts_i)
%SCATTER3_ Summary of this function goes here
%   Detailed explanation goes here

figure, clf, grid on, hold on
set(gca, 'FontName', 'JetBrains Mono')
set(gcf, 'Color', [1 1 1])

scatter3(x(1:end-2), x(2:end-1), x(3:end));

title(['Scatter 3 Plot of X_' ts_i ' (x_{' ts_i '_i} of (x_{' ts_i '_{i-1}}, x_{' ts_i '_{i-2}}))'], ...
    'FontSize', 14, 'FontName', 'JetBrains Mono')
xlabel('x_{i-2}'), ylabel('x_{i-1}'), zlabel(['x_{i}'])
hold off
set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])

end

