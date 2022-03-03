function fn = export_pgf_table(fn,sep,varargin)
%fn = mypgfplots.export_pgf_table(fn,sep,varargin)
%
%   fn  ... output filename
%   sep ... separator
%   varargin    ... columns in pairs {'title1',data1,'title2',data2, ...}
%
% Example:
% mypgfplots.export_pgf_table(fn_out,' ','t_ms',xtmp,'f_MHz',ytmp,'P_dBm',ztmp)


%%
% clc;
% fn = 'test.dat';
% sep = '';
% 
% varargin = {};
% 
% varargin{1} = 'date';
% varargin{2} = datestr(now + (0:9),'dd-mmm-yyyy');
% varargin{3} = 'numbers';
% varargin{4} = (1:10).'*1e-6;

    if isempty(fn)
        fn = [datestr(now,'yyyymmddTHHMMSSFFF'),'.dat'];
    end
    if isempty(sep)
        sep = ',\t';
    end
    strtmp = sprintf("File '%s' exists.",fn);
    if exist(fn,'file')
        warning(strtmp.append(' Overwriting.'));
    end
%     assert(~exist(fn,'file') || misc.confirm_input(strtmp.append(' Overwrite?')),strtmp.append(' Abort.'));
    assert(~isempty(varargin),'No data to write.');
    assert(~mod(numel(varargin),2),'Data must come in pairs: ''titlestring'', datacolumnvector, ...');

    IS_ARRAY_INPUT = true;
    N_cols = size(varargin{2},2);
    for idx = 2:2:numel(varargin)
        data_tmp = varargin{idx};
        assert(numel(size(data_tmp)) == 2,'Max. two dimensional data allowed.');
        IS_ARRAY_INPUT = IS_ARRAY_INPUT && (N_cols == size(data_tmp,2));
    end
%%%
    N_data = size(varargin{2},1);
    varargin_new = {};
    for idx = 1:2:numel(varargin)

        labels_tmp = string(varargin{idx});
        assert(iscolumn(labels_tmp) || isrow(labels_tmp),'Labels must be one dimensional.');
        labels_tmp = labels_tmp(:).';
        N_labels = numel(labels_tmp);


        data_tmp = varargin{idx+1};
        assert(N_data == size(data_tmp,1),'All data must have the same number of rows.');
        if isa(data_tmp,'char') && N_labels == 1
            data_tmp = string(data_tmp).strip();
        end
        if IS_ARRAY_INPUT
            assert(N_labels == 1 && size(data_tmp,2) == N_cols,'Array input must have same number of columns for each data set.');
            varargin_tmp = [ cellstr(labels_tmp) ; ...
                             {data_tmp} ];
        else
            assert(N_labels == size(data_tmp,2),'Number of labels does not fit 2nd dimension of data.');
            varargin_tmp = [ cellstr(labels_tmp) ; ...
                             mat2cell(data_tmp,N_data,ones(1,N_labels)) ];
            N_cols = 1;
        end

        varargin_new = [varargin_new , varargin_tmp(:).'];

    end
    varargin = varargin_new;

    % convert data to strings
    for idx = 2:2:numel(varargin)
        switch class(varargin{idx})
            case 'cell'
                % do nothing
            case 'char'
                varargin{idx} = cellstr(varargin{idx});
            case 'string'
                varargin{idx} = cellstr(varargin{idx});
%             case 'int32' ...
            otherwise
                if IS_ARRAY_INPUT
                    data_tmp = varargin{idx};
                    varargin{idx} = reshape(cellstr(num2str(data_tmp(:))),[N_data,N_cols]);
                else
                    varargin{idx} = cellstr(num2str(varargin{idx}));
                end
        end
    end

    N_fields = numel(varargin)/2;
    N_char_sep = numel(regexprep(sep,'\\.','X'));


    titles = varargin(1:2:end);
    data = varargin(2:2:end);

    fid = fopen(fn,'w');

    assert(fid ~= -1,'Could not open file "%s".',fn);

    towrite = sprintf(['%s' sep],titles{:});
    fprintf(fid,'%s\n\n',towrite(1:end-N_char_sep));

    for ii = 1:N_cols
        for jj = 1:N_data
            towrite = '';
            for kk = 1:N_fields
                data_tmp = data{kk};
                towrite = [towrite , data_tmp{jj,ii} , sep];
            end
            fprintf(fid,'%s\n',towrite(1:end-N_char_sep));
        end
        fprintf(fid,'\n');
    end

    fclose(fid);

end