function [data,tt,ff] = load_VSA_data(filename)
%[data,tt,ff] = load_VSA_data(filename)

    data = load(filename);

    N = numel(data.Y);
    dt = data.XDelta;

    fs = 1/dt;

%     T = (N-1)*dt;
%     tt = 0:dt:T;
%     df = 1/T;
%     ff = (-fs/2:df:fs/2) - mod(N+1,2)*df/2 + data.InputCenter;

    [ tt , ff , ~ ] = init_tt_ff(fs,N);

end