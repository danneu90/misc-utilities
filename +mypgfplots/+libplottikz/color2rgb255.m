function [rgb255,str_rgb255] = color2rgb255(color)
%[rgb255,str_rgb255] = mypgfplots.libplottikz.color2rgb255([color='k'])

    if nargin < 1
        color = [];
    end
    if isempty(color)
        color = 'k';
    end

    if iscell(color)
        rgb255 = cell(size(color));
        str_rgb255 = strings(size(color));
        for ii = 1:numel(color)
            [rgb255{ii},str_rgb255(ii)] = mypgfplots.libplottikz.color2rgb255(color{ii});
        end
        return;
    elseif isstring(color) && numel(color) > 1
        rgb255 = cell(size(color));
        str_rgb255 = strings(size(color));
        for ii = 1:numel(color)
            [rgb255{ii},str_rgb255(ii)] = mypgfplots.libplottikz.color2rgb255(color(ii));
        end
        return;
    end

    if ischar(color) || isstring(color)
        color = string(color).lower();
        switch color
            case 'r'
                color = [1 0 0];
            case 'red'
                color = [1 0 0];
            case 'g'
                color = [0 1 0];
            case 'green'
                color = [0 1 0];
            case 'b'
                color = [0 0 1];
            case 'blue'
                color = [0 0 1];
            case 'c'
                color = [0 1 1];
            case 'cyan'
                color = [0 1 1];
            case 'm'
                color = [1 0 1];
            case 'magenta'
                color = [1 0 1];
            case 'y'
                color = [1 1 0];
            case 'yellow'
                color = [1 1 0];
            case 'k'
                color = [0 0 0];
            case 'black'
                color = [0 0 0];
            case 'w'
                color = [1 1 1];
            case 'white'
                color = [1 1 1];
            otherwise
                error('Invalid color specified "%s".',color);
        end
    end

    assert(isequal(size(color),[1,3]),'Color size not valid, size(color) must be [1,3].');
    assert(all(0 <= color & color <=1),'RGB color values not valid, must be between 0 and 1.');
    rgb255 = round(color*255);

    if nargout > 1
        str_rgb255 = sprintf('{rgb,255:red,%u; green,%u; blue,%u}' , ...
            rgb255(1) , rgb255(2) , rgb255(3) );
        str_rgb255 = string(str_rgb255);
    end

end