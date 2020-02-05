function outputs = select_output(selections,fun,varargin)
%outputs = misc.select_output(selections,fun,varargin)
% EXPERIMENTAL!!!
% Runs "[outputs{:}] = fun(varargin{:})" and returns only outputs specified
% via "selection".

    N = nargout(fun);
    
    assert(max(selections) <= N,'Number of outputs: %u.',N);
    
    outputs_raw = cell(1,N);
    
    [outputs_raw{:}] = fun(varargin{:});
    
    if numel(selections) == 1
        outputs = outputs_raw{selections};
    else
        outputs = outputs_raw(selections);
    end
    
end