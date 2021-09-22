function ls = parse_linestyle(ls)
    ls = string(ls);
    switch ls
        case "-"
            ls = "solid";
        case "--"
            ls = "dashed";
        case ":"
            ls = "dotted";
        case "-."
            ls = "dashdotted";
        otherwise
            erros('Line Style "%s" can not be used.',ls)
    end
end