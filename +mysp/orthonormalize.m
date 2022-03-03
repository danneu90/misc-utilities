function [Son,Acoeff] = orthonormalize(S,limit_norm_dB)
% [Son,Acoeff] = orthonormalize(S)
%
% Orthonormalize S with Gram Schmidt.
% S = Son * Acoeff

    if nargin < 2
        limit_norm_dB = 90;
    end
    limit_norm = 10^(-limit_norm_dB/20);

    Son = S;
    Son = Son ./ vecnorm(Son);
    for ii = 1:size(Son,2)
        for jj = 1:ii-1
            Son(:,ii) = Son(:,ii) - Son(:,jj)'*Son(:,ii) * Son(:,jj);
        end
        norm_i = vecnorm(Son(:,ii));
        if norm_i < limit_norm
            warning('Column %u below defined norm limit. Setting zero.',ii);
            Son(:,ii) = 0;
        else
            Son(:,ii) = Son(:,ii)/norm_i;
        end
    end

    Acoeff = Son'*S;
    
end