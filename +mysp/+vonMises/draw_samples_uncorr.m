function [x] = draw_samples_uncorr(N,kappa,mu)
%[x] = mysp.vonMises.draw_samples_uncorr(N,[kappa=1],[mu=0])

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
    
    dphi = 2*pi/2^20;
    phi = 0:dphi:2*pi-dphi;
    
    pdfvM = mysp.vonMises.pdf_uncorr(phi,kappa,mu);
    cdfvM = cumsum(pdfvM)*dphi;
    
    samp = rand(N,1);
    x = interp1(cdfvM,phi,samp,'pchip');
    
%     figure;
%     plot(cdfvM,phi);
%     grid on;
%     hold on;
%     plot(samp,x,'x');

end