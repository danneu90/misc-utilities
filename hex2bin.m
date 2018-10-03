function bin = hex2bin(hex,n)

    dec = hex2dec(hex);

    if nargin == 2
        bin = dec2bin(dec,n);
    else
        bin = dec2bin(dec);
    end

end