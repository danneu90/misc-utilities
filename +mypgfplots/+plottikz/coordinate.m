function str_tex = coordinate(x,y,varargin)

    assert(isequal(size(x),size(y)),'x and y must be of same size.');

    p = inputParser;
    p.addOptional('axis_flag',false);
    p.addOptional('style_tikz',"");
    p.addOptional('label',"");

    p.KeepUnmatched = true;
    p.parse(varargin{:});

    is_axis = logical(p.Results.axis_flag);
    if numel(is_axis) == 1
        is_axis = repmat(is_axis,size(x));
    end
    assert(isequal(size(is_axis),size(x)),'is_axis must be logical scalar or given for each x,y');

    style_tikz = p.Results.style_tikz;
    if (ischar(style_tikz) && isrow(style_tikz)) || iscellstr(style_tikz)
        style_tikz = string(style_tikz);
    end
    assert(isstring(style_tikz),'style_tikz must be string or cellstr');
    if numel(style_tikz) == 1
        style_tikz = repmat(style_tikz,size(x));
    end
    assert(isequal(size(style_tikz),size(x)),'style_tikz must be string scalar or given for each x,y');

    label = p.Results.label;
    if (ischar(label) && isrow(label)) || iscellstr(label)
        label = string(label);
    end
    assert(isstring(label),'label must be string or cellstr');
    if numel(label) == 1
        label = repmat(label,size(x));
    end
    assert(isequal(size(label),size(x)),'label must be string scalar or given for each x,y');

    str_tex = "";
    for ii = 1:numel(x)
        str = "\coordinate";
        if style_tikz(ii).strlength
            str = str + " [" + style_tikz(ii) + "]";
        end
        if label(ii).strlength
            str = str + " (" + label(ii) + ")";
        end
        str = str + " at";
        str = str + " (";
        if ~isempty(is_axis(ii))
            str = str + "axis cs: ";
        end
        str = str + sprintf("%f,%f",x(ii),y(ii)) + ")";
        str = str + ";" + newline;
        str_tex = str_tex + str;
    end

end