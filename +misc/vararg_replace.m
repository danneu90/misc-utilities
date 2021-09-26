function vararg = vararg_replace(vararg,key,value,CASESENSITIVE,APPEND,DELETEKEY)

% parse input
    if nargin < 3
        value = [];
    end
    if nargin < 4
        CASESENSITIVE = [];
    else
        CASESENSITIVE = logical(CASESENSITIVE);
    end
    if nargin < 5
        APPEND = [];
    else
        APPEND = logical(APPEND);
    end
    if nargin < 6
        DELETEKEY = [];
    else
        DELETEKEY = logical(DELETEKEY);
    end
    if isempty(CASESENSITIVE)
        CASESENSITIVE = true;
    end
    if isempty(APPEND)
        APPEND = false;
    end
    if isempty(DELETEKEY)
        DELETEKEY = isempty(value);
        if DELETEKEY
            warning('Empty value defaults to DELETEKEY=true. Set DELETEKEY manually to avoid this.');
        end
    end
    assert(~DELETEKEY || isempty(value) ,'DELETEKEY only allowed with empty value.');

    assert(iscell(vararg) && isrow(vararg),'vararg must be row cell.');
    assert(~mod(numel(vararg),2),'vararg has to have even number of entries.');
    assert(all(cellfun(@(x) (ischar(x) && isrow(x)) || (isstring(x) && numel(x) == 1),vararg(1:2:end))),'Every second vararg entry has to be a key string.');
    vararg(1:2:end) = cellfun(@(x) char(x),vararg(1:2:end),'UniformOutput',false);

% find replacing index
    if CASESENSITIVE
        idx_key = 2*find(strcmp(vararg(1:2:end),key)) - 1;
    else
        idx_key = 2*find(strcmpi(vararg(1:2:end),key)) - 1;
    end
    
    if isempty(idx_key) && ~DELETEKEY
        if APPEND
            warning('Key "%s" not found. Appending key-value pair.',key);
        else
            error('Key "%s" not found. Try case insensitive or append setting.',key);
        end
    else
        APPEND = false;
    end
    if numel(idx_key) > 1
        if CASESENSITIVE
            if DELETEKEY
                warning('Key "%s" occurs %u times. Removing all.',key,numel(idx_key));
            else
                warning('Key "%s" occurs %u times. Replacing all.',key,numel(idx_key));
            end
        else
            error('Key "%s" occurs %u times. Try case sensitive setting.',key,numel(idx_key));
        end
    end
    
    if APPEND
        vararg = [vararg , {key,value}];
    elseif DELETEKEY
        vararg(idx_key + [0;1]) = [];
    else
        for ii = 1:numel(idx_key)
            vararg{idx_key(ii) + 1} = value;
        end
    end
    
end