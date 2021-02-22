close('all'), clear, clc

%=====================
n0 = 400;
T_a = 5;
T_b = 5;
choice_a = 'c';
choice_b = 'c';
lambda_std_a = 1.5;
lambda_std_b = sqrt(2);
display = true;
%=====================

for ts_i = ['a', 'b']
    %% Set hyperparameters
    eval(['T = T_' ts_i ';']);
    eval(['choice = choice_' ts_i ';']);
    eval(['lambda_std = lambda_std_' ts_i ';']);

    %% Compute Mean Change Points (MCPs)
    [mcps,~,e] = get_mcps(ts_i, display, n0, T, choice, lambda_std);
    fprintf('NRMSE = %.3f\n', e);

   
    if ts_i == 'a'
        c = input('Continue with Y_b? Y/N [Y]:', 's');
        if ~(isempty(c) || c == 'y' || c == 'Y')
            disp('OK, Breaking...')
            break;
        end
    end
    
end
