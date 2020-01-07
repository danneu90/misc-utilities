function structarray_out = parfor_metered(loopfun,structarray_in,percent_bar_varargin)
%structarray_out = parfor_metered(loopfun,structarray_in,percent_bar_varargin[optional])
%
% "structarray_out(idx) = loopfun(structarray_in(idx))" run in parfor loop 
% over idx = 1:numel(structarray_in).
%
% percent_bar_varargin (optional) will be parsed through to percent_bar constructor.

    if nargin < 3
        percent_bar_varargin = {};
    end
    
    percent_bar_varargin = process_percent_bar_varargin(percent_bar_varargin);
    pb = percent_bar(percent_bar_varargin{:});
    
    try
        struct_out = loopfun(structarray_in(1));
    catch ME
        rethrow(ME);
    end
    
    N = numel(structarray_in);
    structarray_out = repmat(struct_out,size(structarray_in));
    
    cnt = 1;
    D = parallel.pool.DataQueue;
    afterEach(D,@nUpdatePercentBar);
    
    pb.init_loop();
    parfor idx = 1:N
        structarray_out(idx) = loopfun(structarray_in(idx));
        send(D,idx);
    end
    
    function nUpdatePercentBar(~)
        pb.iteration_finished(cnt/N);
        cnt = cnt + 1;
    end

end


function percent_bar_varargin = process_percent_bar_varargin(percent_bar_varargin)

    percent_bar_varargin_stored = percent_bar_varargin;
    try
        p_pb = inputParser;
        p_pb.KeepUnmatched = true;
        p_pb.addParameter('name','');
        p_pb.parse(percent_bar_varargin{:});

        percent_bar_varargin = {};
        fieldnames_pbv = fieldnames(p_pb.Unmatched);
        for ii = 1:numel(fieldnames_pbv)
            percent_bar_varargin{end+1} = fieldnames_pbv{ii};
            percent_bar_varargin{end+1} = p_pb.Unmatched.(fieldnames_pbv{ii});
        end

        fieldnames_pbv = fieldnames(p_pb.Results);
        for ii = 1:numel(fieldnames_pbv)
            percent_bar_varargin{end+1} = fieldnames_pbv{ii};
            if strcmp(fieldnames_pbv{ii},'name')
                name_tmp = p_pb.Results.(fieldnames_pbv{ii});
                if isempty(name_tmp)
                    name_tmp = 'Percent Bar';
                end
                percent_bar_varargin{end+1} = [name_tmp , ' (parfor)'];
            end
        end
    catch
        percent_bar_varargin = percent_bar_varargin_stored;
        warning('Adding ''(parfor)'' postfix to percent_bar name failed.');
    end
    
end