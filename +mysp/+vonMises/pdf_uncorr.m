function [pdfvM,log_pdfvM] = pdf_uncorr(x,kappa,mu)
%[pdfvM,log_pdfvM] = mysp.vonMises.pdf_uncorr(x,[kappa=1],[mu=0])

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

    assert(isequal(size(x),size(kappa)) || numel(kappa) == 1,'kappa must be either one element or of equal size as x.');
    assert(isequal(size(x),size(mu)) || numel(mu) == 1,'mu must be either one element or of equal size as x.');

    if numel(kappa) == 1
        kappa = repmat(kappa,size(x));
    end
    if numel(mu) == 1
        mu = repmat(mu,size(x));
    end
    
    assert(any(kappa(:) >= 0),'kappa must be greater than or equal zero.');

    pdfvM = 1./(2*pi*besseli(0,kappa)) .* exp(kappa.*cos(x - mu));
    if nargout > 1
        log_pdfvM = -log(2*pi*besseli(0,kappa)) + kappa .* cos(x - mu);
    end
    if any(isnan(pdfvM(:))) || any(pdfvM(:) == 0) || any(isinf(pdfvM(:)))
        mu = mod(mu,2*pi);
        x = mod(x,2*pi);
        pdfvM = 1./sqrt(2*pi./kappa) .* exp(-(mod(x - mu + pi,2*pi)-pi).^2./(2./kappa));
        if nargout > 1
            log_pdfvM = -1/2*log(2*pi./kappa) - (mod(x - mu + pi,2*pi)-pi).^2./(2./kappa);
        end
    end
    
end