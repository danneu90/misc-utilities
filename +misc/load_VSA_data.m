function [data,tt,ff] = load_VSA_data(filename,filename_calfile)
%[data,tt,ff] = load_VSA_data(filename,filename_calfile)

    if nargin == 1
        filename_calfile = {};
    end

    data = load(filename);

    N = numel(data.Y);
    dt = data.XDelta;

    fs = 1/dt;

    [ tt , ff , ~ ] = misc.init_tt_ff(N,fs);

    if ~isempty(filename_calfile)
        data.Y = misc.deembed_VSA_data(data,filename_calfile);
    end

end






