function kappa = circvar2kappa(circvar)
%kappa = mysp.vonMises.circvar2kappa(circvar)

    mustBeLessThanOrEqual(circvar,1);
    mustBeGreaterThanOrEqual(circvar,0);

    is_0 = circvar == 0;
    is_1 = circvar == 1;

    kappa = ones(size(circvar));
    circvar(is_0 | is_1) = 0.5;

    opt.Display = 'none';
    for ii = 1:numel(circvar)
        if is_0(ii) || is_1(ii)
            continue;
        end
        f = @(x) abs(circvar(ii) - mysp.vonMises.kappa2circvar(x));
        kappa(ii) = fmincon(f,1,[],[],[],[],0,[],[],opt);
    end

    kappa(is_0) = inf;
    kappa(is_1) = 0;

end

