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

    %% Find delay, \tau
    i_tau = mutualinformation(x_deseasoned, 20, ceil(sqrt(length(x_deseasoned)/5)));
    tau = find(islocalmin(i_tau(:, 2))) - 1;
    tau = tau(1);
    fprintf('\t- tau_%c = %d | ', ts_i, tau)
    
    %% Find embedding dimension
    mmax = 10;
    fnnM = falsenearest(x_deseasoned(1:400), 2, mmax);
    m = find(fnnM(:, 2) <= 0.01);
    m = m(1);
    fprintf('m_%c = %d\n', ts_i, m)
    
    %% Check performance on initial timeseries
%     y_hat = (x_hat + y_sqrt(1:end-1)).^2;
%     figure, clf, grid on, hold on
%     set(gca, 'FontName', 'JetBrains Mono')
%     set(gcf, 'Color', [1 1 1])
%     plot(y, '.-b')
%     plot([y(1); y_hat], '.-r')
%     title(['Y_' ts_i ' vs. Y_{' ts_i '_{hat}} Time History Plot'], 'FontSize', 14)
%     set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
%     hold off
    
%     if ts_i == 'a'
%         c = input('Continue with Y_b? Y/N [Y]:', 's');
%         if ~(isempty(c) || c == 'y' || c == 'Y')
%             disp('OK, Breaking...')
%             break;
%         end
%     end
end
