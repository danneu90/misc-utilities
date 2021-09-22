function str_tex_size = parse_tex_fontsize(fontsize)
    if nargin < 1
        fontsize = [];
    end
    if isempty(fontsize)
        fontsize = 4; %normalsize
    end
    
    fontsize_list = [ "tiny" , ...
                      "scriptsize" , ...
                      "footnotesize" , ...
                      "small" , ...
                      "normalsize" , ...
                      "large" , ...
                      "Large" , ...
                      "LARGE" , ...
                      "huge" , ...
                      "Huge" ];
    
    if isnumeric(fontsize)
        switch fontsize
            case 0
                str_tex_size = fontsize_list(1);
            case 1
                str_tex_size = fontsize_list(2);
            case 2
                str_tex_size = fontsize_list(3);
            case 3
                str_tex_size = fontsize_list(4);
            case 4
                str_tex_size = ""; %\normalsize
            case 5
                str_tex_size = fontsize_list(6);
            case 6
                str_tex_size = fontsize_list(7);
            case 7
                str_tex_size = fontsize_list(8);
            case 8
                str_tex_size = fontsize_list(9);
            case 9
                str_tex_size = fontsize_list(10);
            otherwise
                error("fontsize must be in the range 0 (tiny) - 4 (normalsize) - 9 (Huge)");
        end
    else
        str_tex_size = string(fontsize).strip('left','\');
        assert(ismember(str_tex_size,fontsize_list),'Label font size must be one of: "%s" (is %s).',fontsize_list.join(', '),fontsize);
    end
    str_tex_size = string("\").append(str_tex_size);
end