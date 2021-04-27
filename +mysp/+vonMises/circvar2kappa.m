function kappa = circvar2kappa(circvar,err_lim_dB)
%kappa = mysp.vonMises.circvar2kappa(circvar,[err_lim_dB = -50])
%
% err_lim_dB tries to get error for circvar below this value.
% Does not work for low values of circvar. The lower err_lim_dB, the longer
% the time to calculate.

    mustBeLessThanOrEqual(circvar,1);
    mustBeGreaterThanOrEqual(circvar,0);

    if nargin < 2
        err_lim_dB = -50;
    end

    N_samp = max(100,10*round(10^(-err_lim_dB/20)));

    kappa_list = [0 logspace(-6,6,N_samp)];

    if any(0 < circvar & circvar < mysp.vonMises.kappa2circvar(max(kappa_list)))
        warning('Cannot resolve sqrt(circvar) < %f deg. Assuming it to be zero.',sqrt(mysp.vonMises.kappa2circvar(max(kappa_list)))/pi*180)
        circvar(circvar < mysp.vonMises.kappa2circvar(max(kappa_list))) = 0;
    end

    is_0 = circvar == 0;
    is_1 = circvar == 1;

    circvar_list = mysp.vonMises.kappa2circvar(kappa_list);

    [circvar_list,I] = unique(circvar_list);
    kappa_list = kappa_list(I);

    kappa(is_0) = inf;
    kappa(is_1) = 0;
    kappa(~(is_0 | is_1)) = interp1(circvar_list,kappa_list,circvar(~(is_0 | is_1)));

end

