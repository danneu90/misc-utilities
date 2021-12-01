function fn_out = export_pgf_data(fn_out,varargin)
%fn_out = mypgfplots.export_pgf_data(fn_out,varargin)
%
% options with leadin '-':
%   -check_label .. allow sep character in label if false, default true
%   -overwrite  ... overwrite file if exists, default true
%   -output     ... output file type, default table
%   -nan_string ... replace NaN values with this string, default NaN
%   -omit_label ... don't print first label line in table, default false
%   -sep        ... column separator character, default \t
%   -newline    ... newline character, default \n
%   -array_sep  ... if data input is in array format, columns of arrays
%                   will be put below each other in table, separated by
%                   this character, default \n
%   -mkdir      ... if true, creates folder structure for output file
%                   location if not existing, default true
%   -omitemptyrow . if all entries of a row are empty, don't print this row
%                   at all, default false

    assert(~mod(numel(varargin),2),'varargin must come in pairs. Did you mean to use old version? Now found as mypgfplots.export_pgf_table');

    varargin_opt = {};
    data_labels = strings(0);
    data_all = {};
    N_data = [];
    N_data_cols = [];

    IS_MULTI_LABEL = false;
    IS_ARRAY_INPUT = false; % write columns of data below each other separated by col_sep
    for ii = 1:2:numel(varargin)
        label = varargin{ii};
        data = varargin{ii+1};

        assert(isstring(label) || iscellstr(label) || (ischar(label) && isrow(label)),'Odd numbered varargins must be data label (possibly array) or option label (leading ''-'').');

        label = string(label);

        if any(label.startsWith('-')) % option
            assert(numel(label) == 1,'Option must be string scalar. Is [%s].',string('"' + label + '"').join(', '));
            varargin_opt{end+1} = label.strip('left','-');
            varargin_opt{end+1} = data;
        else % data
            assert(numel(size(data)) == 2,'Only 2-dimensional data input allowed.');
            assert(~iscell(data) || iscellstr(data),'Data cells only allowed for cellstr input.');
            if iscellstr(data)
                data = string(data);
            end

            N_label = numel(label);
            N_cols = size(data,2);
            if N_label > 1 % multi label
                IS_MULTI_LABEL = true;
                assert(isrow(label),'Multiple labels for columns of data set must come as row of strings.');
                assert(N_label == N_cols,'Label array size (%u) must fit number of data set columns (%u).',N_label,N_cols);
                for jj = 1:N_label
                    data_labels(end+1) = label(jj);
                    data_all{end+1} = data(:,jj);
                    N_data_cols(end+1) = 1;
                    N_data(end+1) = size(data,1);
                end
            else
                IS_ARRAY_INPUT = IS_ARRAY_INPUT || (N_cols > 1);
                data_labels(end+1) = label;
                data_all{end+1} = data;                
                N_data_cols(end+1) = N_cols;
                N_data(end+1) = size(data,1);
            end
        end
    end
    assert(all(N_data_cols == N_data_cols(1)),'Array-input requires equally sized arrays as input. Maybe some data is row instead of column?');
    assert(all(N_data == N_data(1)),'All data input must have the same number of rows.');
    assert(~(IS_MULTI_LABEL && IS_ARRAY_INPUT),'Only either multi-label or array-input mode allowed.');
    N_data = N_data(1);
    N_data_cols = N_data_cols(1);

    p = inputParser;

    p.addParameter('check_label',true,@(x) validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('overwrite',true,@(x) validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('output','table',@(x) mustBeTextscalar(x));

    p.addParameter('nan_string','NaN',@(x) mustBeTextScalar(x));

    p.addParameter('omit_label',false,@(x) validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('mkdir',true,@(x) validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('sep','\t',@(x) mustBeTextScalar(x));
    p.addParameter('newline',newline,@(x) mustBeTextScalar(x));
    p.addParameter('array_sep',newline,@(x) mustBeTextScalar(x));
    p.addParameter('omitemptyrow',false,@(x) validateattributes(x,{'logical'},{'scalar'}));

    p.parse(varargin_opt{:});

    assert( p.Results.omit_label || ...
            ~p.Results.check_label || ...
            ~any(data_labels.contains(p.Results.sep)), ...
            'Labels must not contain separator. Consider using check_label=false option.');


    data_str_all = cell(size(data_all));
    data_str_all = strings(N_data,N_data_cols,numel(data_all));
    for ii = 1:numel(data_all)
        data = data_all{ii};

        if isnumeric(data)
            is_nan = isnan(data);
        else
            is_nan = false(size(data));
        end
        switch class(data) % different parsing options for different input data classes
            case 'string'
                data_str = data;
            otherwise
                data_str = string(arrayfun(@(x) num2str(x),data,'UniformOutput',false));
        end
        data_str(is_nan) = p.Results.nan_string;
        N_pad = max(max(data_str.strlength,[],'all'),data_labels(ii).strlength);
        data_labels(ii) = data_labels(ii).pad(N_pad,'left');
        data_str = data_str.pad(N_pad,'left');
        data_str_all(:,:,ii) = data_str;
    end


    assert(p.Results.overwrite || ~exist(fn_out,'file'),'File "%s" exists. Consider using overwrite=true option.',fn_out);

    switch lower(p.Results.output)
        case 'table'
            write_table(fn_out,p.Results,data_labels,data_str_all);
        otherwise
            error('Output type "%s" not implemented.',p.Results.output);
    end

end


function write_table(fn_out,opt,labels,data)

    check_folder(fn_out,opt);

    fid = fopen(fn_out,'w');

    if ~opt.omit_label
        fprintf(fid,labels.join(opt.sep) + opt.newline + opt.array_sep);
    end

    for ii = 1:size(data,2)
        for jj = 1:size(data,1)
            if ~opt.omitemptyrow || any(data(jj,ii,:).strip.strlength)
                fprintf(fid,data(jj,ii,:).join(opt.sep) + opt.newline);
            end
        end
        fprintf(fid,opt.array_sep);
    end

    fclose(fid);

end

function check_folder(fn_out,opt)
    fldr = fileparts(fn_out);
    if ~exist(fldr,'dir')
        assert(opt.mkdir,'Output folder "%s" does not exist. Set -mkdir flag true for automatic folder creation.',fldr);
        warning('Output folder "%s" does not exist. Creating it ...',fldr);
        mkdir(fldr);
    end
end