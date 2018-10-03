function hex = bin2hex(bin,n)

    dec = bin2dec(bin);
    
    if nargin == 2
        hex = dec2hex(dec,n);
    else
        hex = dec2hex(dec);
    end
    
end