function [r_y, hV] = autocorrelation_with_limits(y, maxtau, title_, ...
                                                 alpha, ptest)
%AUTOCORRELATION_WITH_LIMITS Plots the autocorrelation of a discrete
%timeseries and the (1-`alpha`)*100% confidence limits.
%Source: tmp.m
%Author: Prof. Dimitris Kugiumtzis
%INPUTS:
%   y           : the timeseries as an array of scalars
%   maxtau      : maximum lag of autocorrelation
%OUTPUTS:
%   r_y         : the autocorrelation values at lags 0,...,`maxtau`
if nargin == 2
    alpha = 0.05;   % 95% confidence
    title_ = '(Sample) Autocorrelation of Y';
elseif nargin == 3
    alpha = 0.05;
end
if nargin < 5
    ptest = false;
end

% Zero-mean timeseries before computing autocorrelation
y = y - mean(y);

% Compute autocorrelation
n = length(y);
r_y = autocorrelation(y, maxtau);

%% Plot autocorrelation
figure, clf, grid on, hold on
set(gca, 'FontName', 'JetBrains Mono')
set(gcf, 'Color', [1 1 1])
for ii=1:maxtau
    plot(r_y(ii+1,1)*[1 1],[0 r_y(ii+1,2)],'b','linewidth',1.5)
end

% Compute importance limits (from confidence)
zalpha = norminv(1-alpha/2);
autlim = zalpha/sqrt(n);

% Plot limits
plot([0 maxtau+1],[0 0],'k','linewidth',1.5)
plot([0 maxtau+1],autlim*[1 1],'--c','linewidth',1.5)
plot([0 maxtau+1],-autlim*[1 1],'--c','linewidth',1.5)

xlabel('lag (\tau)'), ylabel('r(\tau)')
title(title_, 'FontSize', 14)
set(gcf, 'Position', 1.0e+03*[0.662428571428571   0.361000000000000   1.288571428571428   0.725714285714286])
hold off

%% Plot Portmanteau Test
if ptest
    hV = portmanteauLB(y, maxtau, alpha, ...
        strrep(title_, ' Autocorrelation Plot', '') ...
    );
else
    hV = NaN * ones(maxtau, 1);
end

end

