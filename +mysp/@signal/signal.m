classdef signal < mysp.timefrequencybase
%Signal class inhereting from timefrequencybase.
%
% Option 1:
%   obj = mysp.signal(data,fs,varargin)
%
% Option 2:
%   obj = mysp.signal(fun,N,fs,varargin)
%
% Input:
%   data    ... Data vector/array. (Time domain or frequency domain in first dimension)
%   fun     ... Function handle to produce data vector from time or frequency base.
%   N       ... Number of samples.
%   fs      ... Sampling rate. (Optional. Default = 1)
%   varargin:
%       'domain_td_fd'  ... Domain selection: - 'td' ... Time domain. (Default)
%                                             - 'fd' ... Frequency domain.
%       't0'            ... Zero time.
%       'fc'            ... Center frequency.
%       'TIME_CENTERED' ... If true, time vector is centered about t0. If false, time vector starts at t0.
%       'FREQ_CENTERED' ... If true, frequency vector is centered about fc. If false, frequency vector starts at fc.
%
%   See also mysp.timefrequencybase.

    properties
        x {mustBeNumeric(x),mustBeNonempty(x)} = 0; % Signal in time domain.
    end

    properties (Dependent)
        X {mustBeNumeric(X),mustBeNonempty(X)} = 0; % Signal in frequency domain.
    end

    methods

        function obj = signal(data,varargin)

            FUN_HANDLE = isa(data,'function_handle');

            p = inputParser;
            if FUN_HANDLE
                p.addRequired('fun',@(x) isa(x,'function_handle'));
                p.addRequired('N',@(x) assert(x == round(x) && x > 0 && isscalar(x),'2nd argument N must be nonegative scalar integer.'));
            else
                p.addRequired('x',@(x) validateattributes(x,{'numeric'},{'nonempty'}));
            end
            p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'scalar','real','nonnegative'}));
            p.addParameter('domain_td_fd','td',@(x) mustBeMember(x,{'td','fd'}));

            p.KeepUnmatched = true;
            p.parse(data,varargin{:});

            varargin_super = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
            varargin_super = varargin_super.';

            if FUN_HANDLE
                N = p.Results.N;
            else
                N = size(data,1);
            end

            if N == 1
                warning('1st dimension of input is 1.');
            end

            obj = obj@mysp.timefrequencybase(N,p.Results.fs,varargin_super{:});

            if FUN_HANDLE
                if strcmpi(p.Results.domain_td_fd,'td')
                    xx = obj.tt;
                else
                    xx = obj.ff;
                end
                Hdata = p.Results.fun(xx);
            else
                Hdata = p.Results.x;
            end

            if strcmpi(p.Results.domain_td_fd,'td')
                obj.x = Hdata;
            else
                obj.X = Hdata;
            end

        end

        function obj = set.x(obj,x)
            assert(size(x,1) == obj.N,'x must have %u elements in first dimension.',obj.N);
            if obj.TIME_CENTERED
                obj.x = ifftshift(x,1);
            else
                obj.x = x;
            end
        end

        function x = get.x(obj)
            if obj.TIME_CENTERED
                x = fftshift(obj.x,1);
            else
                x = obj.x;
            end
        end

        function obj = set.X(obj,X)
            assert(size(X,1) == obj.N,'X must have %u elements in first dimension.',obj.N);
            if obj.FREQ_CENTERED
                HX = ifftshift(X,1);
            else
                HX = X;
            end
            obj.x = ifft(HX,[],1)*sqrt(obj.N);
        end

        function X = get.X(obj)
            HX = fft(obj.x,[],1)/sqrt(obj.N);
            if obj.FREQ_CENTERED
                X = fftshift(HX,1);
            else
                X = HX;
            end
        end

    end

end
