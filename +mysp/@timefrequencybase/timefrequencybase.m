classdef timefrequencybase
%obj = mysp.timefrequencybase(N,fs,varargin)
%
% Input:
%   N   ... Number of samples.
%   fs  ... Sampling rate. (Optional. Default = 1)
%   varargin:
%       't0'            ... Zero time.
%       'fc'            ... Center frequency.
%       'TIME_CENTERED' ... If true, time vector is centered about t0. If false, time vector starts at t0.
%       'FREQ_CENTERED' ... If true, frequency vector is centered about fc. If false, frequency vector starts at fc.

    properties
        N(1,1)  {mustBeNumeric(N), mustBeGreaterThan(N,0), mustBeReal(N), mustBeInteger(N)} = 1; % Number of samples.
        fs(1,1) {mustBeNumeric(fs),mustBeGreaterThan(fs,0),mustBeReal(fs)} = 1; % Sampling rate.
        t0(1,1) {mustBeNumeric(t0),mustBeReal(t0)} = 0; % Zero time.
        fc(1,1) {mustBeNumeric(fc),mustBeReal(fc)} = 0; % Center frequency.
    end

    properties (Dependent)
        T; % Total duration.
        dt; % Time resolution.
        df; % Frequency resolution.
        tt; % Time vector.
        ff; % Frequency vector.
    end

    properties
        TIME_CENTERED(1,1) logical; % If true, time vector is centered about t0. If false, time vector starts at t0.
        FREQ_CENTERED(1,1) logical; % If true, frequency vector is centered about fc. If false, frequency vector starts at fc.
    end

    methods
        function obj = timefrequencybase(N,varargin)

            p = inputParser;
            p.addRequired('N',@(x) assert(x == round(x) && x > 0 && isscalar(N),'N must be nonegative scalar integer.'));
            p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'scalar','real','nonnegative'}));
            p.addParameter('t0',0,@(x) validateattributes(x,{'numeric'},{'scalar','real'}));
            p.addParameter('fc',0,@(x) validateattributes(x,{'numeric'},{'scalar','real','positive'}));
            p.addParameter('TIME_CENTERED', false, @(x) validateattributes(logical(x),{'logical'},{'scalar'}));
            p.addParameter('FREQ_CENTERED', true,  @(x) validateattributes(logical(x),{'logical'},{'scalar'}));

            p.parse(N,varargin{:});

            obj.fs = p.Results.fs;
            obj.N = p.Results.N;
            obj.t0 = p.Results.t0;
            obj.fc = p.Results.fc;
            obj.TIME_CENTERED = logical(p.Results.TIME_CENTERED);
            obj.FREQ_CENTERED = logical(p.Results.FREQ_CENTERED);

        end

        function T = get.T(obj)
            T = (obj.N - 1)*obj.dt;
        end

        function dt = get.dt(obj)
            dt = 1/obj.fs;
        end

        function df = get.df(obj)
            df = 1/obj.T;
        end

        function tt = get.tt(obj)
            if obj.TIME_CENTERED
                tt = ((-(obj.N-1):2:(obj.N-1)).' - mod(obj.N-1,2)) * obj.dt/2;
            else
                tt = (0:obj.N-1).'*obj.dt;
            end
            tt = tt + obj.t0;
        end

        function ff = get.ff(obj)
            if obj.FREQ_CENTERED
                ff = ((-(obj.N-1):2:(obj.N-1)).' - mod(obj.N-1,2)) * obj.df/2;
            else
                ff = (0:obj.N-1).'*obj.df;
            end
            ff = ff + obj.fc;
        end

    end

end
