function [ tt , ff , full ] = init_tt_ff(fs,N)
%[ tt , ff , full ] = init_tt_ff(fs,N)

    dt = 1/fs;
    T = (N-1)*dt;
    df = 1/T;

    tt = (0:dt:T).';
    ff = (-fs/2:df:fs/2).' - mod(N+1,2)*df/2;

    ff = ff - ff(abs(ff) == min(abs(ff)));
    
    full.tt = tt;
    full.ff = ff;
    full.dt = dt;
    full.T = T;
    full.df = df;

end