function str_tex = text(x,y,str,varargin)

    assert(~mod(numel(varargin),2),'even number of vararg required');

    assert(isequal(size(x),size(y)),'x and y must be of same size.');
    N = numel(x);

    p = inputParser;
    p.addOptional('offset',0,@(x) mustBeNumeric(x));
    p.addOptional('direction_deg',0,@(x) mustBeNumeric(x));
    p.addOptional('rotation_deg',0,@(x) mustBeNumeric(x));
    p.addOptional('fontsize',[]);
    p.addOptional('color',[]);
    p.addOptional('options_node',strings(0));

    p.parse(varargin{:});

    str = string(str);
    if numel(str) == 1
        str = repmat(str,size(x));
    else
        assert(isequal(size(str),size(x)),'Either single text for all points or specific texts for each point required.');
    end

% offset
    offset = p.Results.offset;
    if numel(offset) == 1
        offset = repmat(offset,size(x));
    else
        assert(isequal(size(offset),size(x)),'Either single text offset for all points or specific text offsets for each point required.');
    end

% text offset direction
    direction = p.Results.direction_deg/180*pi;
    if numel(direction) == 1
        direction = repmat(direction,size(x));
    else
        assert(isequal(size(direction),size(x)),'Either single text direction for all points or specific text directions for each point required.');
    end

% text rotation
    rotation_deg = mod(p.Results.rotation_deg,360);
    if numel(rotation_deg) == 1
        rotation_deg = repmat(rotation_deg,size(x));
    else
        assert(isequal(size(rotation_deg),size(x)),'Either single text rotation for all points or specific text rotations for each point required.');
    end

% fontsize
    fontsize = mypgfplots.libplottikz.parse_tex_fontsize(p.Results.fontsize);

% color
    color = p.Results.color;
    if isempty(color)
        str_rgb255 = "";
    else
        [~,str_rgb255] = mypgfplots.libplottikz.color2rgb255(color);
    end
    if numel(str_rgb255) == 1
        str_rgb255 = repmat(str_rgb255,size(x));
    else
        assert(isequal(size(str_rgb255),size(x)),'Either single text color for all points or specific text colors for each point required.');
    end

% other node options
    options_node = p.Results.options_node(:);
    assert(isempty(options_node) || isstring(options_node),'options_node must be array of strings. Color/rotation setting overrule text=color,rotate=deg option.');

% start
    x_true = x + offset .* cos(direction);
    y_true = y + offset .* sin(direction);

    str_tex = string();
    for ii = 1:N

        str_opt = options_node;
        if strlength(str_rgb255(ii))
            str_opt(str_opt.startsWith('text=')) = [];
            str_opt(end+1) = string("text=").append( ...
                str_rgb255(ii));
        end
        if rotation_deg(ii) ~= 0
            str_opt(str_opt.startsWith('rotate=')) = [];
            str_opt(end+1) = string("rotate=").append( ...
                string(rotation_deg(ii)));
        end
        if ~isempty(fontsize)
            str_opt(str_opt.startsWith('font=')) = [];
            str_opt(end+1) = string("font=").append( ...
                string(fontsize));
        end

        str_tex = str_tex.append("\node");

        if ~isempty(str_opt)
            str_tex = str_tex.append(" [").append(str_opt.join(', ')).append('] ');
        end

        str_tex = str_tex.append(' at ');
        str_tex = str_tex.append( ...
            sprintf("(axis cs: %f,%f)",x_true(ii),y_true(ii)));

        str_tex = str_tex.append(" {");
        str_tex = str_tex.append( ...
            sprintf("%s}",str(ii)));

        str_tex = str_tex.append(';').append(newline);
    end

end