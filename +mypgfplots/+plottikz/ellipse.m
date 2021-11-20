function str_tex = ellipse(A,xc,varargin)
%str_tex = mypgfplots.plottikz.ellipse(A,xc,varargin)
%
% Returns pgf plot string for rendering.
% 2-D ellipse centered at xc and defined with a symmetric
% matrix A as
%   (x - xc).'*A*(x - xc) = 1
%
% Requires pgf compatibility 1.5.1, e.g. \pgfplotsset{compat=1.5.1}

    [Vell,Dell] = eig(A);
    assert(isreal(Dell) && all(diag(Dell) > 0),'Ellipse matrix not valid.');

    if det(Vell) < 0 % if V contains reflection, remove it, as it is not required for ellipse plotting
        Vell = Vell * [1 0 ; 0 -1];
    end
    rot_deg = atan2(Vell(2,1),Vell(1,1))/pi*180;
    x_r = 1/sqrt(Dell(1,1));
    y_r = 1/sqrt(Dell(2,2));
    x_c = xc(1);
    y_c = xc(2);

    p = inputParser;
    p.addOptional('style_tikz','');
    p.KeepUnmatched = true;
    p.parse(varargin{:});

    def.Color = 'k';
    def.LineWidth = 1;
    def.LineStyle = '-';
    if ~isempty(p.Results.style_tikz)
        def.Color = '';
        def.LineWidth = [];
        def.LineStyle = '';
    end
    p.addOptional('Color',def.Color);
    p.addOptional('LineWidth',def.LineWidth);
    p.addOptional('LineStyle',def.LineStyle);
    p.addOptional('legend_entry','');

    p.KeepUnmatched = true;
    p.parse(varargin{:});

    str_opt = strings(0);
    if ~isempty(p.Results.style_tikz)
        str_opt(end+1) = string(p.Results.style_tikz);
    end
    if ~isempty(p.Results.Color)
        [~,str_rgb255] = mypgfplots.libplottikz.color2rgb255(p.Results.Color);
        str_opt(end+1) = string("color=").append(str_rgb255);
    end
    if ~isempty(p.Results.LineStyle)
        ls = mypgfplots.libplottikz.parse_linestyle(p.Results.LineStyle);
        str_opt(end+1) = ls;
    end
    if ~isempty(p.Results.LineWidth)
        lw = p.Results.LineWidth/4;
        str_opt(end+1) = string("line width=").append(string(lw));
    end

    leg = string(p.Results.legend_entry);
    ISLEGEND = ~(isempty(leg) || all(leg.strlength == 0));

    str_opt_ell = [str_opt , sprintf("rotate around={%f:(axis cs: %f,%f)}" , ...
                    rot_deg , x_c , y_c ) ];

    str_tex = "\draw";
    str_tex = str_tex.append(" [").append(str_opt_ell.join(', ')).append('] ');
    str_tex = str_tex.append(sprintf("(axis cs: %f,%f)",x_c,y_c));
    str_tex = str_tex.append(" ellipse ");
    str_tex = str_tex.append(sprintf("(%f and %f)",x_r,y_r));
    str_tex = str_tex.append(';').append(newline);

    if ISLEGEND
        str_tex = str_tex.append("\addlegendimage{").append(str_opt.join(', ')).append('}');
        str_tex = str_tex.append(';').append(newline);
        str_tex = str_tex.append("\addlegendentry{").append(leg).append('}');
        str_tex = str_tex.append(';').append(newline);
    end

end