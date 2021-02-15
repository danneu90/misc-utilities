function lbi = log_besseli(nu,z)
%lbi = log_besseli(nu,z)
%
% Calculate log of the modified Bessel function of first kind.
% For large z (> 800), a third order approximation is used.
    
    assert(isscalar(nu),'nu must be scalar.');

    log_besseli_approx = @(z) z - 1/2*log(2*pi*z) + log( 1 ...
                                                    - (4*nu^2-1)./(8*z) ...
                                                    + (4*nu^2-1)*(4*nu^2-9)./(2*8^2*z.^2) ...
                                                    - (4*nu^2-1)*(4*nu^2-9)*(4*nu^2-25)./(6*8^3*z.^3));
    
    lbi = log(besseli(nu,z));
    
    is_out_of_bound = isinf(lbi);

    if any(is_out_of_bound) 
        if all(abs(angle(z)) < pi/2)
            lbi(is_out_of_bound) = log_besseli_approx(z(is_out_of_bound));        
            lbi(isinf(z) & isnan(lbi)) = sign(z(isinf(z) & isnan(lbi))) * inf;
        else
            warning('approximation only works for abs(angle(z)) < pi/2');
        end
    end

end
