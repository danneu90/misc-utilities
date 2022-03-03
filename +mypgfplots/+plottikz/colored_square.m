function str_tex = colored_square(corners,meta_values)

    if nargin < 2
        meta_values = [];
    end
    if isempty(meta_values)
        assert(isequal(size(corners),[3,4]),'corners must be 3x4 matrix. (x,y & four corners) if no meta_value(s) given');
    else
        assert(isequal(size(corners),[2,4]),'corners must be 2x4 matrix. (x,y & four corners)');
        if numel(meta_values) == 1
            meta_values = repmat(meta_values,[1,4]);
        else
            assert(numel(meta_values) == 4,'either meta value for each corner or one value for all');
        end
        corners = [corners ; meta_values];
    end



% % make string (addplot3 coordinates)
%     str_tex = "\addplot3 [patch,patch type=rectangle,faceted color=none,opacity=0.8] coordinates {" ...
%                 + string("(" + string(corners.').join(',',2) + ")").join(' ') ...
%                 + "}";

% make string (addplot table)
    str_tex = "\addplot [patch,patch type=rectangle] table [point meta=\thisrow{z}] {" ...
                + "x y z" + newline ...
                + string(sprintf('\t') + string(corners.').join(' ',2)).join(newline) ...
                + newline + "}";

    str_tex = str_tex + ";" + newline;

end