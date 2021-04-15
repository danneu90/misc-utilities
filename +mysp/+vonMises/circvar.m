function circvar = circvar(kappa)
%circvar = mysp.vonMises.circvar(kappa)

    mustBeGreaterThanOrEqual(kappa,0);
    circvar = 1 - exp(mysp.log_besseli(1,kappa) - mysp.log_besseli(0,kappa));
    circvar(isinf(kappa)) = 0;
    circvar(kappa == 0) = 1;

end