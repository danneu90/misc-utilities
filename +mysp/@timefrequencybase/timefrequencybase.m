classdef timefrequencybase
%obj = mysp.timefrequencybase(N,fs,varargin)
%
% Input:
%   N   ... Number of samples.
%   fs  ... Sampling rate. (Optional. Default = 1)
%   varargin:
%       't0'            ... Zero time. (Default = 0)
%       'fc'            ... Center frequency. (Default = 0)
%       'TIME_CENTERED' ... If true, time vector is centered about t0. (Use fftshift for data.)
%                           If false, time vector starts at t0.
%                           (Default = false)
%       'FREQ_CENTERED' ... If true, frequency vector is centered about fc. (Use fftshift for data.)
%                           If false, frequency vector starts at fc.
%                           (Default = false)
%
% See also fftshift, misc.init_tt_ff.

    properties
        N(1,1)  {mustBeNumeric(N), mustBeGreaterThanOrEqual(N,0), mustBeReal(N), mustBeInteger(N)}; % Number of samples.
        fs(1,1) {mustBeNumeric(fs),mustBeGreaterThan(fs,0),mustBeReal(fs)} = 1; % Sampling rate.
        t0(1,1) {mustBeNumeric(t0),mustBeReal(t0)} = 0; % Zero time.
        fc(1,1) {mustBeNumeric(fc),mustBeReal(fc)} = 0; % Center frequency.
    end

    properties (Dependent = true, Transient = true)
        T; % Total duration.
        dt; % Time resolution.
        df; % Frequency resolution.
        tt; % Time vector.
        ff; % Frequency vector.

        t_start; % first time sample
        t_stop;  % last time sample
        tlim;    % limits of time axis
        f_start; % first freq sample
        f_stop;  % last freq sample
        flim;    % limits of freq axis
    end

    properties
        TIME_CENTERED(1,1) logical; % If true, time vector is centered about t0. If false, time vector starts at t0.
        FREQ_CENTERED(1,1) logical; % If true, frequency vector is centered about fc. If false, frequency vector starts at fc.
    end

    properties (SetAccess = private, Hidden = true, Transient = true)
        nn;
    end

    methods

        function obj = timefrequencybase(N,varargin)

            [N,fs,param] = obj.parse_input(N,varargin{:});

            if numel(N) == 1
                obj.fs = fs;
                obj.N = N;
                obj.t0 = param.t0;
                obj.fc = param.fc;
                obj.TIME_CENTERED = param.TIME_CENTERED;
                obj.FREQ_CENTERED = param.FREQ_CENTERED;
            else
                obj = repmat(mysp.timefrequencybase(1),size(N));
                for ii = 1:numel(N)
                    obj(ii) = mysp.timefrequencybase(N(ii),fs(ii), ...
                        't0' , param.t0(ii) , ...
                        'fc' , param.fc(ii) , ...
                        'TIME_CENTERED' , param.TIME_CENTERED(ii) , ...
                        'FREQ_CENTERED' , param.FREQ_CENTERED(ii) );
                end
            end

        end

        function obj = upsample(obj,N_us)
            assert(N_us > 1,'N_us must be greater than 1');
            assert(N_us == round(N_us),'N_us must be integer');
            obj.N = obj.N * N_us;
            obj.fs = obj.fs * N_us;
        end

        function eq = eq(obj,obj0)
            eq = all( ([obj.N] == [obj0.N]) ...
                    & ([obj.fs] == [obj0.fs]) ...
                    & ([obj.t0] == [obj0.t0]) ...
                    & ([obj.fc] == [obj0.fc]) ...
                    & ([obj.TIME_CENTERED] == [obj0.TIME_CENTERED]) ...
                    & ([obj.FREQ_CENTERED] == [obj0.FREQ_CENTERED]) ,'all');
        end

        function obj = set.N(obj,N)
            obj.N = N;
            obj.nn = (0:N-1).';
        end

        function T = get.T(obj)
            T = obj.N*obj.dt;
        end

        function dt = get.dt(obj)
            dt = 1/obj.fs;
        end

        function df = get.df(obj)
            df = 1/obj.T;
        end

        function nn = get.nn(obj)
            if ~isempty(obj.nn)
                nn = obj.nn;
            else % for loading of instance
                nn = (0:obj.N-1).';
            end
        end

        function tt = get.tt(obj)
            nn_loc = obj.nn;
            if obj.TIME_CENTERED
                nn_loc = nn_loc - (obj.N - mod(obj.N,2))/2;
            end
            tt = nn_loc * obj.dt;
            tt = tt + obj.t0;
        end

        function ff = get.ff(obj)
            nn_loc = obj.nn;
            if obj.FREQ_CENTERED
                nn_loc = nn_loc - (obj.N - mod(obj.N,2))/2;
            end
            ff = nn_loc * obj.df;
            ff = ff + obj.fc;
        end

        function t_start = get.t_start(obj)
            t_start = obj.t0;
            if obj.TIME_CENTERED
                t_start = t_start - obj.dt * (obj.N - mod(obj.N,2))/2;
            end
        end

        function t_stop = get.t_stop(obj)
            t_stop = obj.t_start + obj.T - obj.dt;
        end

        function tlim = get.tlim(obj)
            tlim = obj.t_start + [0 obj.T - obj.dt];
        end

        function f_start = get.f_start(obj)
            f_start = obj.fc;
            if obj.FREQ_CENTERED
                f_start = f_start - obj.df * (obj.N - mod(obj.N,2))/2;
            end
        end

        function f_stop = get.f_stop(obj)
            f_stop = obj.f_start + obj.fs - obj.df;
        end

        function flim = get.flim(obj)
            flim = obj.f_start + [0 obj.fs - obj.df];
        end

    end

    methods (Access = private, Static = true)

        function [N,fs,param] = parse_input(N,varargin)

            p = inputParser;
            p.addRequired('N',@(x) assert(all(x == round(x) & x > 0),'N must be nonegative integer.'));
            p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'real','positive'}));
            p.addParameter('t0',0,@(x) validateattributes(x,{'numeric'},{'real'}));
            p.addParameter('fc',0,@(x) validateattributes(x,{'numeric'},{'real','nonnegative'}));
            p.addParameter('TIME_CENTERED', false, @(x) validateattributes(logical(x),{'logical'},{}));
            p.addParameter('FREQ_CENTERED', true,  @(x) validateattributes(logical(x),{'logical'},{}));

            p.parse(N,varargin{:});
            N = p.Results.N;
            fs = p.Results.fs;
            t0 = p.Results.t0;
            fc = p.Results.fc;
            TIME_CENTERED = logical(p.Results.TIME_CENTERED);
            FREQ_CENTERED = logical(p.Results.FREQ_CENTERED);

            if numel(N) == 1 && numel(fs) > 1
                N = repmat(N,size(fs));
            elseif numel(N) > 1 && numel(fs) == 1
                fs = repmat(fs,size(N));
            else
                assert(isequal(size(N),size(fs)),'N and fs not of equal size.');
            end

            if numel(t0) > 1
                assert(isequal(size(N),size(t0)),'t0 must be either scalar or of same size as N/fs.');
            else
                t0 = repmat(t0,size(N));
            end
            if numel(fc) > 1
                assert(isequal(size(N),size(fc)),'fc must be either scalar or of same size as N/fs.');
            else
                fc = repmat(fc,size(N));
            end
            if numel(TIME_CENTERED) > 1
                assert(isequal(size(N),size(TIME_CENTERED)),'TIME_CENTERED must be either scalar or of same size as N/fs.');
            else
                TIME_CENTERED = repmat(TIME_CENTERED,size(N));
            end
            if numel(FREQ_CENTERED) > 1
                assert(isequal(size(N),size(FREQ_CENTERED)),'t0 must be either scalar or of same size as N/fs.');
            else
                FREQ_CENTERED = repmat(FREQ_CENTERED,size(N));
            end

            param.t0 = t0;
            param.fc = fc;
            param.TIME_CENTERED = TIME_CENTERED;
            param.FREQ_CENTERED = FREQ_CENTERED;

        end

    end

end
