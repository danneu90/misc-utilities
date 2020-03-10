function bin = hex2bin(hex,n)
%bin = misc.hex2bin(hex,n)

    if numel(hex) >= 2 && strcmpi(hex(1:2),'0x')
        hex(1:2) = '';
    end

    if numel(hex) >= 1 && strcmpi(hex(1),'x')
        hex(1) = '';
    end

    dec = hex2dec(hex);

    if nargin == 2
        bin = dec2bin(dec,n);
    else
        bin = dec2bin(dec);
    end

end