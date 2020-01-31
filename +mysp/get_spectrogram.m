function [P_dBmperHz,TTspec,FFspec] = get_spectrogram(x,fs,tres,fres,win,Z0)
%[P_dBmperHz,TTspec,FFspec] = mysp.get_spectrogram(x,fs,tres,fres,[win],[Z0])

    if nargin < 5
        win = [];
    end
    if nargin < 6
        Z0 = [];
    end
    if isempty(win)
        win = @blackmanharris;
%         win = @hann;
%         win = @(x) ones(x,1);
    end
    if isempty(Z0)
        Z0 = 50;
    end

    Ntres = floor(tres*fs);

    idxttspec = 1:Ntres:numel(x);
    ttspec = (idxttspec(:)-1)/fs;
    
    Nfres = ceil(fs/fres);
    
    [~,ffspec] = misc.init_tt_ff(Nfres,fs);

    dfspec = median(diff(ffspec));
    
    idxspec = idxttspec + (0:Nfres-1).' - ceil(Nfres/2);
    ttspec(min(idxspec) < 1) = nan;
    ttspec(max(idxspec) > numel(x)) = nan;
    ttspec(isnan(ttspec)) = [];
    idxspec(:,min(idxspec) < 1) = [];
    idxspec(:,max(idxspec) > numel(x)) = [];
    
    x_spec = x(idxspec);
    
    winweights = win(size(x_spec,1));
    winweights = winweights/sqrt(sum(abs(winweights).^2)/Nfres);
    
    X_spec = fftshift(fft(winweights.*x_spec,[],1),1)/size(x_spec,1);
    
    [FFspec,TTspec] = ndgrid(ffspec,ttspec);
    
    PW_Hz = abs(X_spec).^2/(2*Z0)/dfspec;
    P_dBmperHz = 10*log10(PW_Hz) + 30;

end