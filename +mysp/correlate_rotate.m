function [cor,tt] = correlate_rotate(varargin)
%corr = correlate_rotate(x,xseq,fs,varargin)
%
% Rotates xseq samplewise over x and returns the correlation for each of
% those points. For limited bandwidth.
%
% Required:
%   x           ... Data.
%   xseq        ... Rotate xseq over x and correlate.
% Optional:
%   fs          ... Common sample frequency. (Default: 1, i.e. index based)
% Parameter:
%   BW          ... Matched filter bandwidth. If BW < fs, x and xseq will
%                   be downsampled using resample. Otherwise it will be ignored.
%                   TAKE CARE that x and xseq are within this bandwidth.
%   weights     ... Weights xseq according to values of positive real
%                   weights vector of same size as xseq. Makes it slower.
% Other parameter:
%   ram_limit_GB .. RAM limit in GByte. (Default: 6)
%   verboselevel ..  0 nothing
%                    1 warnings (Default)
%                    2 plots

%% input parser

    VERBOSELEVEL_def = 1;
    ram_limit_def_GB = 6;

    p = inputParser;

    p.addRequired('x',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addRequired('xseq',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
    p.addParameter('BW',inf,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
    p.addParameter('weights',[],@(x) validateattributes(x,{'numeric'},{'column','real','nonnegative'}));
    p.addParameter('ram_limit_GB',ram_limit_def_GB,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('verboselevel',VERBOSELEVEL_def,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));

    p.parse(varargin{:});

    x = p.Results.x;
    xseq = p.Results.xseq;
    fs = p.Results.fs;
    BW = min(fs,p.Results.BW);
    weights = p.Results.weights;
    ram_limit_GB = p.Results.ram_limit_GB;
    VERBOSELEVEL = p.Results.verboselevel;

%% check and prepare input

    if isempty(weights)
        weights = ones(size(xseq));
    end

    assert(numel(xseq) <= numel(x),'x must not have a smaller number of element than xseq.');
    assert(isequal(size(xseq),size(weights)),'weights must have the same size as xseq.');

    x = double(x);
    xseq = double(xseq);

    % resample if BW < fs
    if ~isequal(BW,fs) 
        tt_x = (0:numel(x)-1).'/fs;
        x = resample(x,tt_x,BW);
        tt_xseq = (0:numel(xseq)-1).'/fs;
        xseq = resample(xseq,tt_xseq,BW);
        weights = interp1(tt_xseq,weights,(0:numel(xseq)-1).'/BW,'nearest');
    end

    ram_est_GB = 1.5 * 16*numel(xseq)*numel(x)/2^30;
    assert(ram_est_GB < ram_limit_GB,'Too much RAM requested: %.2f GByte. (RAM limited to %.2f GByte.)',ram_est_GB,ram_limit_GB);

    if VERBOSELEVEL && fs == 1
        if ~isinf(BW)
            warning('fs is 1 Hz. Take care with BW. (BW = %f Hz)',BW);
        end
    end

%% start

    idx_shifted = mod((0:numel(xseq)-1).' + (0:numel(x)-1),numel(x)) + 1;

    xshifted = x(idx_shifted);

    if all(weights == weights(1))
        cor = corr(xseq,xshifted);
    else
        weights = weights/sum(weights);
        m_xshifted = sum(xshifted.*weights);
        m_xseq = sum(xseq.*weights);

        xshifted = xshifted - m_xshifted;
        xseq = xseq - m_xseq;

        s_xshifted = sum(xshifted.^2.*weights);
        s_xseq = sum(xseq.^2.*weights);

        s_cross = sum(xshifted.*xseq.*weights);

        cor = s_cross./sqrt(s_xshifted.*s_xseq);
    end    
    cor = cor(:);

    tt = (0:numel(x)-1).'/BW;

%% plot

    if VERBOSELEVEL > 1
        ttseq = (0:numel(xseq)-1).'/BW;

        if isreal(x) && isreal(xseq)
            yx = x;
            yxseq = xseq;
            ycor = cor;
        else
            yx = abs(x);
            yxseq = abs(xseq);
            ycor = abs(cor);
        end

        figure;
        sp(1) = subplot(2,1,1);
        plot(tt,yx);
        hold on;
        plot(ttseq,yxseq);        
        grid on;

        sp(2) = subplot(2,1,2);
        plot(tt,ycor);

        linkaxes(sp,'x');

    end

end