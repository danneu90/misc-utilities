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
            warning('Non matlab line style "%s".',ls)
    end
end