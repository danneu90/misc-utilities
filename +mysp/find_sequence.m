function [cor_pks,t_pks,width_pks,prominence_pks,cor,tt] = find_sequence(varargin)
%[cor_pks,t_pks,width_pks,prominence_pks,cor,tt] = mysp.find_sequence(x,xseq,fs,varargin)
%
% Uses correlation (matched filter) to slide xseq over x and find multiple 
% occurrences of xseq within x using findpeaks.
%
% Required:
%   x           ... Find xseq in x.
%   xseq        ... Find this.
% Optional:
%   fs          ... Common sample frequency. (Default: 1, i.e. index based)
% Parameter:
%   T_holdoff 	... Time that has to pass before a new peak can be detected. (Default: 0);
%   BW          ... Matched filter bandwidth. If BW < fs, x and xseq will
%                   be downsampled using resample. Otherwise it will be ignored.
%                   TAKE CARE that x and xseq are within this bandwidth.
%   weights     ... Weights xseq according to values of positive real
%                   weights vector of same size as xseq. Makes it slower.
%   real_force  ... Force real valued correlation instead of complex.
%                   I.e. input real, correlation real. (Default: false)
%   peakprominence  Filter for minimum peak prominence in correlation:
%                   MinPeakProminence = peakprominence * MaxPeakProminence
%                   (Default: 0)
%
%   ram_limit_GB .. RAM limit in GByte. (Default: 6)
%   verboselevel ..  0 nothing
%                    1 warnings (Default)
%                    2 plots
%
% Output:
%   *_pks       ... First 4 output parameters correspond to output of findpeaks.
%   cor,tt      ... Correspond to output of mysp.correlate_rotate.

%%
VERBOSELEVEL_def = 1;
ram_limit_def_GB = 6;
real_force_def = false;

    p = inputParser;

    p.addRequired('x',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addRequired('xseq',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
    p.addParameter('T_holdoff',0,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('BW',inf,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
    p.addParameter('weights',[],@(x) validateattributes(x,{'numeric'},{'real','nonnegative'}));
    p.addParameter('real_force',real_force_def,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
    p.addParameter('peakprominence',0,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('ram_limit_GB',ram_limit_def_GB,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('verboselevel',VERBOSELEVEL_def,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));

    p.parse(varargin{:});

    x = p.Results.x;
    xseq = p.Results.xseq;
    fs = p.Results.fs;
    T_holdoff = p.Results.T_holdoff;
    BW = min(fs,p.Results.BW);
    weights = p.Results.weights;
    peakprominence = p.Results.peakprominence;
    VERBOSELEVEL = p.Results.verboselevel;
    ram_limit_GB = p.Results.ram_limit_GB;
    real_force = boolean(p.Results.real_force);

    if isempty(weights)
        weights = ones(size(xseq));
    end

    if VERBOSELEVEL && fs == 1 && T_holdoff ~= 0
        warning('fs is 1 Hz. Take care with T_holdoff.');
    end

%% start

    % real/complex
    x = double(x);
    xseq = double(xseq);

    if real_force
        assert(isreal(x),'x must be real. when "''real_force'' = true".');
        assert(isreal(xseq),'xseq must be real. when "''real_force'' = true".');
    end

    [cor,tt] = mysp.correlate_rotate(x(1:numel(x)-numel(xseq)),xseq,fs,'BW',BW,'weights',weights,'ram_limit_GB',ram_limit_GB,'verboselevel',VERBOSELEVEL);

    N_sample_holdoff = floor(T_holdoff*BW);

    if real_force
        % imaginary part theoretically must be zero anyway in the real case
        cor_peakfind = real(cor);
    else
        cor_peakfind = abs(cor);
    end

    % find all correlation peaks
    [cor_pks,idx_pks,width_pks,prominence_pks] = findpeaks(cor_peakfind,'MinPeakDistance',N_sample_holdoff);

    % filter peak promincence
    if peakprominence
        MinPeakProminence = peakprominence*max(prominence_pks);
        if VERBOSELEVEL
            warning('MinPeakProminence set to %.3f.',MinPeakProminence);
        end
    else
        MinPeakProminence = 0;
    end

    filter_peak_prominence = prominence_pks >= MinPeakProminence;
    cor_pks         = cor_pks       (filter_peak_prominence);
    idx_pks         = idx_pks       (filter_peak_prominence);
    width_pks       = width_pks     (filter_peak_prominence);
    prominence_pks  = prominence_pks(filter_peak_prominence);

    % t_pks
    t_pks = (idx_pks-1)/BW;

%% plots

    if VERBOSELEVEL > 1

        figure;

        [tt,ff] = misc.init_tt_ff(numel(x),fs);
        [ttseq,ffseq] = misc.init_tt_ff(numel(xseq),fs);
        [ttcor,ffcor] = misc.init_tt_ff(numel(cor),BW);

        sp(1) = subplot(3,1,1);
        plot(tt,x);
        hold on;
        plot(ttseq,xseq);
        grid on;

        sp(2) = subplot(3,1,2);
        plot(tt,20*log10(abs(x)));
        hold on;
        plot(ttseq,20*log10(abs(xseq)));
        grid on;

        sp(3) = subplot(3,1,3);
        findpeaks(cor_peakfind,ttcor,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',T_holdoff,'Annotate','extents');
        hold on;
        plot(t_pks,cor_pks,'x','LineWidth',10);
        grid on;
        ylim([-1 1]);
        set(get(gca,'legend'),'location','southeast');

        linkaxes(sp,'x');
        
        xlim(tt([1,end]));

    end

end