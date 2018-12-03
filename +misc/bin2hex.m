function hex = bin2hex(bin,n)

    if strcmpi(bin(1:2),'0b')
        bin(1:2) = '';
    end

    if strcmpi(bin(1),'b')
        bin(1) = '';
    end

    dec = bin2dec(bin);

    if nargin == 2
        hex = dec2hex(dec,n);
    else
        hex = dec2hex(dec);
    end

end