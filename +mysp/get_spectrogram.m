function [P_dBmperHz,TTspec,FFspec] = get_spectrogram(x,fs,tres,fres,win,Z0)
%[P_dBmperHz,TTspec,FFspec] = mysp.get_spectrogram(x,fs,tres,fres,[win=blackmanharris],[Z0=50])

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

    assert(iscolumn(x),'x must be column vector.');
    assert(isscalar(fs)   && fs   > 0,'fs must be non-negative scalar.');
    assert(isscalar(tres) && tres > 0,'tres must be non-negative scalar.');
    assert(isscalar(fres) && fres > 0,'fres must be non-negative scalar.');
    assert(isscalar(Z0)   && Z0   > 0,'Z0 must be non-negative scalar.');

    Ntres = floor(tres*fs);
    assert(Ntres > 0,'tres (= %s) must be greater than or equal 1/fs (= 1/(%s) = %s).',misc.unit_parser(tres,'unit','s'),misc.unit_parser(fs,'unit','hz'),misc.unit_parser(1/fs,'unit','s'));

    idxttspec = 1:Ntres:numel(x);
    ttspec = (idxttspec(:)-1)/fs;
    
    Nfres = ceil(fs/fres);
    assert(Nfres > 1,'fres (= %s) must be smaller than fs (= %s).',misc.unit_parser(fres,'unit','hz'),misc.unit_parser(fs,'unit','hz'));
    
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