function fn_out = export_contour_object(fn_out,contobj)

    contmat = contobj.ContourMatrix;
    levels = contobj.LevelList;

    line_levels = [];
    x = cell(0);
    y = cell(0);
    while ~isempty(contmat)
        line_levels(end+1) = contmat(1,1);
        n_tmp = contmat(2,1);
        contmat(:,1) = []; % remove level info
        assert(~(n_tmp - round(n_tmp)),'number of vertices for level "%f" is not an integer',line_levels(end));

        x{end+1} = contmat(1,1:n_tmp);
        y{end+1} = contmat(2,1:n_tmp);
        contmat(:,1:n_tmp) = []; % remove level data
    end

    N_cont = numel(x);
    N_max = max(cellfun(@(elem) numel(elem),x));

    XX = nan(N_max,N_cont);
    YY = nan(N_max,N_cont);
    ZZ = nan(N_max,N_cont);
    for ii = 1:N_cont
        N_tmp = numel(x{ii});
        XX(1:N_tmp,ii) = x{ii};
        YY(1:N_tmp,ii) = y{ii};
        ZZ(1:N_tmp,ii) = line_levels(ii);
    end

    varargin_data = {'x',XX,'y',YY,'z',ZZ};

    mypgfplots.export_pgf_data(fn_out,'-nan_string','','-omitemptyrow',true,varargin_data{:});

end