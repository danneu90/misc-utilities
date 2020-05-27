function githash = githash(objname)
%githash = misc.githash(objname)
%
% Gets hash of current commit. If possible.

    if nargin < 1
        objname = [];
    end
    if isempty(objname)
        objname = pwd;
        warning('Input empty, getting githash for pwd: "%s".',objname);
    end

    try
        assert(ischar(objname) || isstring(objname),'''objname'' must be name of folder, file, or function in search path.');
        if isfolder(objname)
            D = dir(objname);
            location_obj = D(1).folder;
        else
            location_obj = fileparts(which(objname));
            assert(isfolder(location_obj),['Cmd "fileparts(which(''',objname,'''))" did not return a valid folder.' , newline , ...
                'Returned "' , location_obj '" instead.']);
        end

        [status,githash] = system(['cd ',location_obj,' && git rev-parse HEAD']);
        githash = strtrim(githash);

        if status || ~all(ismember(lower(githash),'0123456789abcdef'))
            warning(['Result does not seem to be a valid git hash: ''%s''' , ...
                newline , '   input  = ''%s''' , ...
                newline , '   target = ''%s''' ...
                ],githash,objname,location_obj);
        end
    catch ME
        githash = ['misc.githash error: "' , ME.message , '"'];
    end
    
end