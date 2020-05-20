function num = num_parser(strarray)
%%
    strarray = string(strarray);

    strarray = strarray.strip;

    neg = strarray.startsWith('-');
    strarray = strarray.strip('left','-');
    
    num = arrayfun(@(x) my_str2num(x), strarray);
    num(neg) = -num(neg);
    
end

function num = my_str2num(str)

    num = double(str2num(str));
    if isempty(num)
        num = nan;
    end

end