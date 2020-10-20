function bytes_cum = disp_struct_size(input_struct,level)
%bytes_cum = misc.disp_struct_size(input_struct)
%
% Recurses into struct and displays the size of all fields.
% Returns cummulative size in bytes.
%
% TODO: print also size of substructs (where?!)

    if nargin < 2
        level = 0;
    end

    assert(isstruct(input_struct) && numel(input_struct) == 1 ,'Input must be scalar struct.');

    fns = fieldnames(input_struct);
    N_spc = max(cellfun(@(x) numel(x),fns)) + 1;
    bytes_cum = 0;

    if level == 0
        fprintf('%sSTRUCT:\n',repmat('   ',[1,level]));
    end
    for fld = fns.'
        tmp = input_struct.(fld{1});
        str_name = [repmat('\t',[1,level]) , sprintf('%s :',fld{1})];
        if isstruct(tmp)
            fprintf([str_name,'\n']);
            bytes_cum = bytes_cum + misc.disp_struct_size(tmp,level+1);
        else
            S = whos('tmp');
            bytes = S.bytes;
            bytes_cum = bytes_cum + bytes;
            fprintf([str_name , ...
                repmat(' ',[1 N_spc-numel(fld{1})]) , ...
                '%s\n'],misc.unit_parser(bytes,'unit','Byte'));
        end
    end

end