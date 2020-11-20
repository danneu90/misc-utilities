function resp = scpi(h,msg)
%resp = scpi(h,msg)
% Checks if msg ends with ? and uses fprintf/query to communicate with interface h, accordingly.
% resp is query output, empty for fprintf

    msg = string(msg);
    msg = msg.strip('both');

    if msg.endsWith('?')
        resp = query(h,msg);
    else
        fprintf(h,msg);
        resp = [];
    end

end
