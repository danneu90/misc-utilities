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
    end

    properties
        TIME_CENTERED(1,1) logical; % If true, time vector is centered about t0. If false, time vector starts at t0.
        FREQ_CENTERED(1,1) logical; % If true, frequency vector is centered about fc. If false, frequency vector starts at fc.
    end

    properties (Access = private, Transient = true)
        nn;
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

    end

end
