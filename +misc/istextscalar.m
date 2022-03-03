function status = istextscalar(A)
%status = misc.istextscalar(A)
%
% Returns true is mustBeTextScalar(A) succeeds, false otherwise.

    try
        mustBeTextScalar(A);
        status = true;
    catch ME
        if ismember(ME.identifier,{'MATLAB:validators:mustBeTextScalar'})
            status = false;
        else
            rethrow(ME);
        end
    end
end