function [mu_est,kappa_est] = est_moments_uncorr(x,VERBOSE)
%[mu_est,kappa_est] = mysp.vonMises.est_moments_uncorr(x,[VERBOSE=false])

    if nargin < 2
        VERBOSE = [];
    end
    if isempty(VERBOSE)
        VERBOSE = false;
    end
    
    x = x(:);
    N = numel(x);

    mu_est = angle(mean(exp(1i*x)));

    R_bar_squared = sum(cos(x)/N)^2 + sum(sin(x)/N)^2;
    R_e_squared = N/(N-1)*(R_bar_squared - 1/N);
    R_e = sqrt(max(R_e_squared,0));

    kappa_init = 1;
    kappa_est = solve_I1_per_I0(R_e,kappa_init,VERBOSE);

end


function kappa_est = solve_I1_per_I0(Re,kappa_init,VERBOSE)

dkappa_target = 1e-3;
itt_max = 10000;

    if nargin < 3
        VERBOSE = [];
    end
    if isempty(VERBOSE)
        VERBOSE = false;
    end


    Imin1 = @(x) besseli(-1,x);
    I0 = @(x) besseli(0,x);
    I1 = @(x) besseli(1,x);
    I2 = @(x) besseli(2,x);

    f = @(x) I1(x)./I0(x) - Re;
    fprime = @(x) 1/2 * (I0(x).^2 + I0(x).*I2(x) - I1(x).*Imin1(x) - I1(x).^2)./(I0(x).^2);

%     f = @(x) log(I1(x)) - log(I0(x)) - log(Re);
%     fprime = @(x) 1/2 * ((I0(x) + I2(x))./I1(x) - (Imin1(x) + I1(x))./I0(x));

    if VERBOSE
        kappa_plot = -1000:.1:1000;
        figure;
        plot(kappa_plot,f(kappa_plot));
        grid on;
        hold on;
    end
    
    kappa_est = kappa_init;
    N = itt_max;
    for ii = 1:N
        if VERBOSE
            plot(kappa_est,f(kappa_est),'x');
            drawnow;
        end
        dkappa = - f(kappa_est)./fprime(kappa_est);
        if any(isnan(dkappa(:))) || any(isinf(dkappa(:)))
            if VERBOSE
                warning('kappa out of range.');
            end
            break;
        end
        if all(abs(dkappa(:)) < dkappa_target)
            break;
        end
        kappa_est = kappa_est + dkappa;
    end
    if VERBOSE && ii == N
        warning('max. number (%u) of iterations reached.',N);
    end
    
    if any(kappa_est(:) < 0)
        kappa_est(kappa_est < 0) = 0;
        if VERBOSE
            warning('kappa is too close too zero.');
        end
    end
        
end