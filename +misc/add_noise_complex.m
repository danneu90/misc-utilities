function [ x , xn ] = add_noise_complex(xs,SNR_dB)
%[ x , xn ] = misc.add_noise_complex(xs,SNR_dB)
%
% xs is a t-D array. The columns contain signals over time.

    assert(size(xs,1) ~= 1,'xs must be t-D signal(s) in first dimension.');

    Pxs = sum(abs(xs).^2,1)/size(xs,1);

    if any(Pxs == 0)
        warning('add_noise_complex: At least one zero power signal given. SNR concept does not work that way. Nothing will be done.');
    end

    SNR = 10.^(SNR_dB/10);

    sigma_N = sqrt(Pxs/SNR);

    xn = sigma_N/sqrt(2).*(randn(size(xs)) + 1i*randn(size(xs)));

    x = xs + xn;

end