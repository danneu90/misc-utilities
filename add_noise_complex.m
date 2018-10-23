function [ x , xn ] = add_noise_complex(xs,SNR_dB)
%[ x , xn ] = add_noise_complex(xs,SNR_dB)

    assert(size(xs,2) == 1,'xs must be one-dimensional.');
    
    Pxs = sum(abs(xs).^2)/numel(xs);

    SNR = 10.^(SNR_dB/10);
    
    sigma_N = sqrt(Pxs/SNR);

    xn = sigma_N/sqrt(2)*(randn(size(xs)) + 1i*randn(size(xs)));
    
    x = xs + xn;

end