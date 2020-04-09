function [f0_est,SNR_est,A_est] = est_single_sinusoids(x,fs)
% [f0_est,SNR_est,A_est] = mysp.est_single_sinusoid(x,fs)
%
% Estimates the parameters of x = A * exp(1i*2*pi*tt*f0) + w.
% With w additive noise.
% x can be array with different parameters in each column.
%
% Compare S.M.Kay I Ex. 15.13.

    N_x = size(x,1);
    df = fs/N_x;

    X = fft(x,[],1)/N_x;
   
    [~,idx_max] = max(abs(X));
    A_est = diag(X(idx_max,:)).';
    f0_est = (idx_max-1)*df;
    f0_est = f0_est - fs * double(f0_est >= fs/2);
    s2_est = sum(abs(X).^2) - abs(A_est).^2;

    SNR_est = abs(A_est).^2./s2_est;
    
end