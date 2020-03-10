function status = confirm_input(question,default_response)
%status = misc.confirm_input(question,default_response)

    assert(nargin > 0,['Not enough input arguments. Syntax:' newline 'status = confirm_input(question,default_response)']);
    
    if nargin == 1
        default_response = false;
    end

    if boolean(default_response)
        resp_def = 'Y';
    else
        resp_def = 'N';
    end
    
    while 1
        resp = input(sprintf('%s Y/N [%s]: ',question,resp_def),'s');

        if isempty(resp)
            resp = resp_def;
        end

        [X,tf] = str2num(resp);
        if tf
            status = all(boolean(abs(X)));
            break;
        else
            switch lower(resp)
                case 'y'
                    status = 1;
                    break;
                case 'yes'
                    status = 1;
                    break;
                case 'n'
                    status = 0;
                    break;
                case 'no'
                    status = 0;
                    break;
                otherwise
                    continue;
            end
        end
    end
    status = boolean(status);
end