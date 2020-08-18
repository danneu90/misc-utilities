function fn = export_pgf_data(fn,sep,varargin)
%fn = mypgfplots.export_pgf_data(fn,sep,varargin)
%
%   fn  ... output filename
%   sep ... separator
%   varargin    ... columns in pairs {'title1',data1,'title2',data2, ...}
%
% Example:
% mypgfplots.export_pgf_data(fn_out,' ','t_ms',xtmp,'f_MHz',ytmp,'P_dBm',ztmp)


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
    assert(~exist(fn,'file'),'File ''%s'' exists. Abort.',fn);
    assert(~isempty(varargin),'No data to write.');
    assert(~mod(numel(varargin),2),'Data must come in pairs: ''titlestring'', datacolumnvector, ...');

%%%

    for idx = 2:2:numel(varargin)
        switch class(varargin{idx})
            case 'cell'
                % do nothing
            case 'char'
                varargin{idx} = cellstr(varargin{idx});
%             case 'int32' ...
            otherwise
                varargin{idx} = cellstr(num2str(varargin{idx}));
        end
    end
    
    assert(all(cellfun(@(x) isequal(size(varargin{2}),size(x)),varargin(2:2:end))),'All datacolumnvectors must have the same number of elements.');
    assert(iscolumn(varargin{2}),'All datacolumnvectors must be column vectors. Nona.');
    
    N_data = numel(varargin{2});
    N_fields = numel(varargin)/2;
    N_char_sep = numel(regexprep(sep,'\\.','X'));

    
    titles = varargin(1:2:end);
    data = [varargin{2:2:end}];

    fid = fopen(fn,'w');
    
    towrite = sprintf(['%s' sep],titles{:});
    fprintf(fid,'%s\n\n',towrite(1:end-N_char_sep));

    for ii = 1:N_data
        towrite = sprintf(['%s',sep],data{ii,:});
        fprintf(fid,'%s\n',towrite(1:end-N_char_sep));
    end
            
    fclose(fid);

end