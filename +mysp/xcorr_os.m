function [xc,tfs_xc,X,Y,XC] = xcorr_os(x,y,N_os,tfs)
%[xc,tfs_xc,X,Y,XC] = mysp.xcorr_os(x,y,N_os,[tfs])
%
% Calculates xcorr and uses oversampling.

    assert(N_os >= 1 && N_os == round(N_os),'N_os must be integer >= 1.');

    if isempty(y)
        y = x;
    end

    assert(size(x,2) == size(y,2) || size(x,2) == 1 || size(y,2) == 1,'x,y must have either same number of columns or one of them has to have one column and will be repeated for column wise xcorr');

    if nargin < 4
        tfs = mysp.timefrequencybase(size(x,1),1);
    end

    if size(x,2) == 1
        x = repmat(x,size(y,2));
    end
    if size(y,2) == 1
        y = repmat(y,size(x,2));
    end

    tfs = mysp.timefrequencybase(tfs.N,tfs.fs,'time_centered',0,'freq_centered',1); % ensure uniform centering

    X_orig = fftshift(fft(x,[],1),1);
    Y_orig = fftshift(fft(y,[],1),1);

    tfs_xc = mysp.timefrequencybase(tfs.N*N_os,tfs.fs*N_os,'time_centered',1);

    X = zeros(tfs_xc.N,size(x,2));
    Y = zeros(tfs_xc.N,size(x,2));

    % improve this!
    idx_cent = find(tfs.ff == 0);
    idx_cent_xc = find(tfs_xc.ff == 0);

    idx_start = idx_cent_xc - idx_cent + 1;
    idx_stop = idx_start + tfs.N - 1;

    X(idx_start:idx_stop,:) = X_orig;
    Y(idx_start:idx_stop,:) = Y_orig;

    XC = X .* conj(Y);

    xc = fftshift(ifft(ifftshift(XC,1),[],1),1);

end