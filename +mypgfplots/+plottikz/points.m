function str_tex = points(x,y,varargin)

    assert(isequal(size(x),size(y)),'x and y must be of same size.');
    N = numel(x);

    p = inputParser;
    p.addOptional('Marker','x');
    p.addOptional('Rotation_deg',0);
    p.addOptional('Color','k');
    p.addOptional('MarkerSize_pt',2);
    p.addOptional('filled',false);
    p.addOptional('Label','');
    p.addOptional('Label_dir_deg',0);
    p.addOptional('Label_fontsize',[]);
    p.addOptional('legend_entry','');

    p.KeepUnmatched = true;
    p.parse(varargin{:});

    label = string(p.Results.Label);
    ISLABEL = ~(isempty(label) || all(label.strlength == 0));
    if ISLABEL
        if numel(label) == 1
            label = repmat(label,size(x));
        else
            assert(isequal(size(label),size(x)),'Either single label for all points or specific labels for each point required.');
        end
        label_dir_deg = mod(p.Results.Label_dir_deg,360);
        label_fontsize = mypgfplots.libplottikz.parse_tex_fontsize(p.Results.Label_fontsize);
    end

    marker = string(p.Results.Marker);
    if logical(p.Results.filled)
        if strcmp(marker,'o')
            marker = "*";
        else
            marker = marker.append("*");
        end
    end

    rot = mod(p.Results.Rotation_deg,360);

    [~,str_rgb255] = mypgfplots.libplottikz.color2rgb255(p.Results.Color);

    sz = p.Results.MarkerSize_pt/4;


    leg = string(p.Results.legend_entry);
    ISLEGEND = ~(isempty(leg) || all(leg.strlength == 0));

    
% start

    % options
    str_opt = [ "only marks" , ... no connections
                string("color=").append(str_rgb255) , ... color
                string("mark=").append(marker) , ... marker style
                sprintf("every mark/.append style={mark size=%fpt, rotate=%u}" , ...
                    sz , rot ) ...
                ];
    if ~ISLEGEND
        str_opt = [str_opt , "forget plot"];
    end

    str_dat = arrayfun(@(i) ...
        sprintf("(%f,%f)",x(i),y(i)) ...
        ,1:N);


    str_tex = "\addplot";
    str_tex = str_tex.append(" [").append(str_opt.join(', ')).append('] ');
    str_tex = str_tex.append("coordinates");
    str_tex = str_tex.append(" {").append(str_dat.join(' ')).append("}");
    str_tex = str_tex.append(';').append(newline);

    if ISLABEL
        for ii = 1:N
            str_tex = str_tex.append("\node");
            str_tex = str_tex.append( ...
                sprintf("[label={%u:{%s %s}}]",label_dir_deg,label_fontsize,label(ii)));
            str_tex = str_tex.append(' at ');
            str_tex = str_tex.append( ...
                sprintf("(axis cs: %f,%f) {}",x(ii),y(ii)));
            str_tex = str_tex.append(';').append(newline);
        end
    end
    
    if ISLEGEND
        str_tex = str_tex.append("\addlegendentry{").append(leg).append('}');
        str_tex = str_tex.append(';').append(newline);
    end

end