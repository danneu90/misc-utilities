function bin = hex2bin(hex,n)

    if strcmpi(hex(1:2),'0x')
        hex(1:2) = '';
    end

    if strcmpi(hex(1),'x')
        hex(1) = '';
    end

    dec = hex2dec(hex);

    if nargin == 2
        bin = dec2bin(dec,n);
    else
        bin = dec2bin(dec);
    end

end