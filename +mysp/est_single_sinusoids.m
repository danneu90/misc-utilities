function [f0_est,SNR_est,A_est,df] = est_single_sinusoids(x,fs,df)
% [f0_est,SNR_est,A_est,df] = mysp.est_single_sinusoids(x,fs,[df])
%
% Estimates the parameters of x = A * exp(1i*2*pi*tt*f0) + w.
% With w additive noise.
% x can be array with different parameters in each column.
%
% If specified, df determines the desired minimum frequency resolution.
%
% WARNING: SNR estimation fails for high number of samples (> 1e5) because
% of single pin signal which smears in fact over more pins.
%
% For CRLB see comments below.
%
% Compare S.M.Kay I Ex. 15.13.

    if nargin < 3
        df = [];
    end

    N_x = size(x,1);
    if isempty(df)
        x_zp = x;
        N_zp = N_x;
    else
%         N_zp = 2^ceil(log2(fs/df));
        N_zp = ceil(fs/df);
        x_zp = [x ; zeros(N_zp - N_x,size(x,2))];
        N_zp = numel(x_zp);
    end
    df = fs/N_zp;

    X_zp = fft(x_zp,[],1)/N_x;
   
    [~,idx_max] = max(abs(X_zp));
    A_est = diag(X_zp(idx_max,:)).';
    f0_est = (idx_max-1)*df;
    f0_est = f0_est - fs * double(f0_est >= fs/2);

%     x_res = xraw - A_est.*exp(1i*2*pi*misc.init_tt_ff(N_x_raw,fs)*f0_est);
%     s2_est = var(x_res,[],1)
%     s2_est = sum(abs(X_zp).^2)/N_zp*N_x - abs(A_est).^2

    s2_est = sum(abs(x).^2)/N_x - abs(A_est).^2;

    SNR_est = abs(A_est).^2./s2_est;

%     CRLB_absA = s2_est ./ (2*N_x);
%     CRLB_absA = mean(CRLB_absA)
%     CRLB_f0 = 6 ./ ((2*pi)^2 * SNR_est * N_x * (N_x^2-1));
%     CRLB_f0 = mean(CRLB_f0)
%     CRLB_argA = (2*N_x - 1) ./ (SNR_est * N_x * (N_x + 1));
%     CRLB_argA = mean(CRLB_argA)
    
end