function [out_strings] = unit_parser_time(values,SHORT)
%out_strings = unit_parser_time(values,[SHORT=false])

    if nargin < 2
        SHORT = [];
    end
    if isempty(SHORT)
        SHORT = false;
    end

    assert(all(values >= 0,'all') & isreal(values),'Time input must be positive real numbers.');

    str_sep = ", ";
    str_plr = "s";

    T_M = 60;
    T_H = T_M*60;
    T_d = T_H*24;
    T_y = (3*365 + 366)/4 * T_d;
    T_m = T_y/12;

    T = [T_y , T_m , T_d , T_H , T_M].';
    if SHORT
        str_T = ["y","m","d","h","min","sec"];
    else
        str_T = ["year","month","day","hour","min","sec"];
    end

    out_strings = strings(size(values));
    for jj = 1:numel(values)
        tvalue = values(jj);
        t = nan(size(T));
        for ii = 1:numel(T)
            t(ii) = floor(tvalue/T(ii));
            tvalue = tvalue - t(ii)*T(ii);
        end
        t(end+1) = round(tvalue);

        if any(t > 0)
            tstring = "";
            for ii = 1:numel(t)
                if t(ii) > 0
                    tstring = tstring.append(sprintf('%u %s',t(ii),str_T(ii)));
                    if ~SHORT && t(ii) > 1
                        tstring = tstring.append(str_plr);
                    end
                    if ii < numel(t)
                        tstring = tstring.append(str_sep);
                    end
                end
            end
            out_strings(jj) = tstring;
        else
            out_strings(jj) = string("< 1 ").append(str_T(end));
    end

end