function [x] = draw_samples_uncorr(N,kappa,mu,VERBOSE)
%[x] = mysp.vonMises.draw_samples_uncorr(N,[kappa=1],[mu=0],[VERBOSE=false])

    kappa_lim = [1e-6 1e6];

    if nargin < 4
        VERBOSE = [];
    end
    if nargin < 3
        mu = [];
    end
    if nargin < 2
        kappa = [];
    end
    
    if isempty(kappa)
        kappa = 1;
    end
    if isempty(mu)
        mu = 0;
    end
    if isempty(VERBOSE)
        VERBOSE = false;
    end
    
    assert(all(kappa(:) >= 0),'kappa must be greater or equal to zero.');
    
    if numel(N) == 1 || (numel(kappa) == 1 && numel(mu) == 1)

        if numel(N) == 1
            samp = rand(N,1);
        else
            samp = rand(N);
        end

        if kappa > max(kappa_lim)
            x = mu*ones(size(samp));
            if VERBOSE
                warning('kappa > %.2e is too large. Assuming kappa = inf. (everything mu)',max(kappa_lim));
            end
        elseif kappa < min(kappa_lim)
            x = 2*pi*samp;
            if VERBOSE
                warning('kappa < %.2e is too small. Assuming kappa = 0. (uniformly distr.)',min(kappa_lim));
            end
        else

            dphi = 2*pi/max(round(kappa),2^10);
            phi = 0:dphi:2*pi-dphi;

            pdfvM = mysp.vonMises.pdf_uncorr(phi,kappa,mu);
            cdfvM = cumsum(pdfvM)*dphi;

            [cdfvM,idx] = unique(cdfvM);
            phi = phi(idx);
            x = interp1(cdfvM,phi,samp,'pchip');

            if VERBOSE
                figure;
                plot(cdfvM,phi);
                grid on;
                hold on;
                plot(samp,x,'xr');
                xlabel('cdf');
                ylabel('phi (rad)');
            end

        end

        x = mod(x,2*pi);

    else
        assert(isequal(N,size(kappa)) || numel(kappa) == 1,'kappa must be either one element or of equal size as specified via N.');
        assert(isequal(N,size(mu)) || numel(mu) == 1,'mu must be either one element or of equal size as specified via N.');

        if numel(kappa) == 1
            kappa = repmat(kappa,N);
        end
        if numel(mu) == 1
            mu = repmat(mu,N);
        end

        if VERBOSE
            warning('Recurse for kappa/mu array.');
        end
        x = nan(N);
        for ii = 1:prod(N)
            x(ii) = mysp.vonMises.draw_samples_uncorr(1,kappa(ii),mu(ii));
        end
    end
    
end