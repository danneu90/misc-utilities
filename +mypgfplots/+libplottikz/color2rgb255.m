function [rgb255,str_rgb255] = color2rgb255(color)
    if ischar(color)
        switch color
            case 'r'
                color = [1 0 0];
            case 'g'
                color = [0 1 0];
            case 'b'
                color = [0 0 1];
            case 'c'
                color = [0 1 1];
            case 'm'
                color = [1 0 1];
            case 'y'
                color = [1 1 0];
            case 'k'
                color = [0 0 0];
            case 'w'
                color = [1 1 1];
            otherwise
                error('Invalid color specified "%s".',color);
        end
    end
    assert(all(0 <= color & color <=1),'Color value not valid.');
    rgb255 = round(color*255);

    str_rgb255 = sprintf('{rgb,255:red,%u; green,%u; blue,%u}' , ...
        rgb255(1) , rgb255(2) , rgb255(3) );
end