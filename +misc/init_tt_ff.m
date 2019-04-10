function [ tt , ff , full ] = init_tt_ff(N,fs)
%[ tt , ff , full ] = init_tt_ff(N,fs)

    if nargin == 1
        fs = 1;
    end

    dt = 1/fs;
    T = (N-1)*dt;
    df = 1/T;

    tt = (0:dt:T).';
    
    if nargout > 1
        ff = (-fs/2:df:fs/2).' - mod(N-1,2)*df/2;
        ff = ff - ff(abs(ff) == min(abs(ff)));
    end
    
    if nargout > 2
        full.tt = tt;
        full.ff = ff;
        full.dt = dt;
        full.df = df;
        full.T = T;
        full.fs = fs;
        full.N = N;
    end
    
end