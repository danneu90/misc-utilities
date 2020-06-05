function num = num_parser(strarray)
%%
    strarray = string(strarray);

    strarray = strarray.strip;

    neg = strarray.startsWith('-');
    strarray = strarray.strip('left','-');
    
    if all(strarray.lower.startsWith('0x'))
        num = hex2dec(strarray.extractAfter(2));
    else
        num = arrayfun(@(x) my_str2num(x), strarray);
    end
    num(neg) = -num(neg);
    
end

function num = my_str2num(str)

    if str.lower.startsWith('0x')
        num = hex2dec(str.extractAfter(2));
    else
        num = double(str2num(str));
    end
    if isempty(num)
        num = nan;
    end

end