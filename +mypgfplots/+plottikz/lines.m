function str_tex_list = lines(x,y,varargin)

    assert(isequal(size(x),size(y)) || (iscolumn(x) && numel(x) == size(y,1)),'x and y must be of same size.');
    if isrow(x)
        x = x.';
        y = y.';
    end
    if iscolumn(x) && numel(x) == size(y,1)
        x = repmat(x,[1,size(y,2)]);
    end

    p = inputParser;
    p.addOptional('Color','k');
    p.addOptional('LineWidth',0.5);
    p.addOptional('LineStyle','-');

    p.KeepUnmatched = true;
    p.parse(varargin{:});

    [~,str_rgb255] = mypgfplots.libplottikz.color2rgb255(p.Results.Color);
    lw = p.Results.LineWidth/4;
    ls = mypgfplots.libplottikz.parse_linestyle(p.Results.LineStyle);

    N = size(x,1);
    M = size(x,2);
    str_tex_list = strings(1,M);
    for jj = 1:M
        % options
        str_opt = [ string("draw=").append(str_rgb255) , ... color
                    ls , ... line style
                    string("line width=").append(string(lw)) , ... line width
                    ];

        % data
        str_dat = arrayfun(@(i) ...
            sprintf("(axis cs: %f,%f)",x(i,jj),y(i,jj)) ...
            ,1:N);

        % join
        str_tex = "\draw";
        str_tex = str_tex.append(" [").append(str_opt.join(', ')).append('] ');
        str_tex = str_tex.append(str_dat.join(' -- '));
        str_tex = str_tex.append(';').append(newline);

        str_tex_list(jj) = str_tex;
    end
end

