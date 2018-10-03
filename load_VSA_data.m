function [data,tt,ff] = load_VSA_data(filename)

    data = load(filename);

    y = data.Y;
    dt = data.XDelta;

    N = numel(y);
    
    T = (N-1)*dt;    
    tt = 0:dt:T;

    df = 1/T;
    fs = 1/dt;
    
    ff = (-fs/2:df:fs/2) - mod(N+1,2)*df/2 + data.InputCenter;
    
end