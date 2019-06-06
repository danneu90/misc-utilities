function [t_pks,cor_pks,peak_prominence,peak_width,cor] = find_sequence(varargin)
%[t_pks,cor_pks,peak_prominence,peak_width,cor] = misc.find_sequence(x,xseq,fs,varargin)
%
% Uses correlation (matched filter) to slide xseq over x and find multiple 
% occurrences of xseq within x.
%
% Required:
%   x           ... Find xseq in x.
%   xseq        ... Find this.
% Optional:
%   fs          ... Common sample frequency. (Default: 1, i.e. index based)
% Parameter:
%   T_holdoff 	... Time that has to pass before a new peak can be detected. (Default: 0);
%   real_force  ... Force real valued correlation instead of complex.
%                   I.e. input real, correlation real. (Default: false)
%   MinPeakProminence ... Minimum peak prominence in correlation.
%                   (Default: 3/4 of max peak prominence.)
%                   TODO: find better solution.
%
%   ram_limit_GB .. RAM limit in GByte. (Default: 6)
%   verboselevel ..  0 nothing
%                    1 warnings (Default)
%                    2 plots


%%%
VERBOSELEVEL_def = 1;
ram_limit_def_GB = 6;
real_force_def = false;

    p = inputParser;

    p.addRequired('x',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addRequired('xseq',@(x) validateattributes(x,{'numeric'},{'column'}));
    p.addOptional('fs',1,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
    p.addParameter('T_holdoff',0,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('real_force',real_force_def,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
    p.addParameter('MinPeakProminence',[],@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('ram_limit_GB',ram_limit_def_GB,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('verboselevel',VERBOSELEVEL_def,@(x) validateattributes(x,{'numeric'},{'scalar','nonnegative'}));

    p.parse(varargin{:});

    x = p.Results.x;
    xseq = p.Results.xseq;
    fs = p.Results.fs;
    T_holdoff = p.Results.T_holdoff;
    MinPeakProminence = p.Results.MinPeakProminence;
    VERBOSELEVEL = p.Results.verboselevel;
    ram_limit_GB = p.Results.ram_limit_GB;
    real_force = boolean(p.Results.real_force);


    ram_est_GB = 2 * 16*numel(xseq)*(numel(x)-numel(xseq))/2^30;
    assert(ram_est_GB < ram_limit_GB,'Too much RAM requested: %.2f GByte. (RAM limited to %.2f GByte.)',ram_est_GB,ram_limit_GB);


    if VERBOSELEVEL && fs == 1 && T_holdoff ~= 0
        warning('fs is 1 Hz. Take care with T_holdoff.');
    end

    N_sample_holdoff = floor(T_holdoff*fs);

%% start

    % real/complex
    x = double(x);
    if real_force
        assert(isreal(x),'x must be real. when "''real_force'' = true".');
    end
    xseq = double(xseq);
    if real_force
        assert(isreal(xseq),'xseq must be real. when "''real_force'' = true".');
    end

    % prepare data
    x_shifted = x((1:numel(xseq)).' + (1:(numel(x) - numel(xseq))));
    x_shifted = x_shifted - mean(x_shifted);
    X_shifted = fft(x_shifted,[],1);
    p_X_shifted = sum(abs(X_shifted).^2);
    X_shifted = X_shifted ./ sqrt(p_X_shifted);

    % prepare sequence
    xseq = xseq - mean(xseq);
    Xsequence = fft(xseq,[],1);
    p_Xsequence = sum(abs(Xsequence).^2);
    Xsequence = Xsequence ./ sqrt(p_Xsequence);

    % correlation
    cor_raw = X_shifted'*Xsequence;
    if real_force
        % imaginary part theoretically must be zero in the real case
        cor = real(cor_raw);
    else
        cor = abs(cor_raw);
    end

    % find all correlation peaks
    [cor_pks,idx_pks,peak_width,peak_prominence] = findpeaks(cor,'MinPeakDistance',N_sample_holdoff);

    % filter peak promincence
    if isempty(MinPeakProminence)
        MinPeakProminence = 3/4*max(peak_prominence);
    else
        if VERBOSELEVEL
            warning('MinPeakProminence set to %.3f.',MinPeakProminence);
        end
    end

    filter_peak_prominence = peak_prominence >= MinPeakProminence;
    cor_pks         = cor_pks        (filter_peak_prominence);
    idx_pks         = idx_pks        (filter_peak_prominence);
    peak_width      = peak_width     (filter_peak_prominence);
    peak_prominence = peak_prominence(filter_peak_prominence);

    % apply holdoff
    filter_holdoff = diff([0;idx_pks]) >= N_sample_holdoff;
    cor_pks         = cor_pks        (filter_holdoff);
    idx_pks         = idx_pks        (filter_holdoff);
    peak_width      = peak_width     (filter_holdoff);
    peak_prominence = peak_prominence(filter_holdoff);

%     % drop the last match (will not be entirly within the data)
%     cor_pks(end)         = [];
%     idx_pks(end)         = [];
%     peak_width(end)      = [];
%     peak_prominence(end) = [];

    % t_pks
    t_pks = (idx_pks-1)/fs;

%% plotting

    if VERBOSELEVEL > 1

        figure;

        [tt,ff] = misc.init_tt_ff(numel(x),fs);
        [ttseq,ffseq] = misc.init_tt_ff(numel(xseq),fs);
        [ttcor,ffcor] = misc.init_tt_ff(numel(cor),fs);

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
        findpeaks(cor,ttcor,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',T_holdoff,'Annotate','extents');
        hold on;
        plot(t_pks,cor_pks,'x','LineWidth',10);
        grid on;
        set(get(gca,'legend'),'location','southeast');

        linkaxes(sp,'x');
        
        xlim(tt([1,end]));

    end

end