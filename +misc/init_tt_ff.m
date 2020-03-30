function [ tt , ff , full , timefrequencybase] = init_tt_ff(N,fs)
%[ tt , ff , full , timefrequencybase] = misc.init_tt_ff(N,fs)

    timefrequencybase_class = 'mysp.timefrequencybase';

    if nargin == 1
        fs = 1;
    end

    dt = 1/fs;
    T = N*dt;
    df = 1/T;

    nn = (0:N-1).';
    tt = nn * dt;
    if nargout > 1
        ff = (nn - (N - mod(N,2))/2) * df;
    end

    if nargout > 2
        full.tt = tt;
        full.ff = ff;
        full.dt = dt;
        full.df = df;
        full.T = T;
        full.fs = fs;
        full.N = N;

        timefrequencybase = [];
        if exist(timefrequencybase_class,"class")
            timefrequencybase_class_call = sprintf('%s(N,fs)',timefrequencybase_class);
            try
                timefrequencybase = eval(timefrequencybase_class_call);
                full.timefrequencybase = timefrequencybase;
            catch ME
                full.ME = ME;
                warning('Class call ''%s'' failed with message "%s". Added ME to output struct.',timefrequencybase_class_call,ME.message);
            end
        else
            warning('Class ''%s'' not found.',timefrequencybase_class);
        end
    end

end