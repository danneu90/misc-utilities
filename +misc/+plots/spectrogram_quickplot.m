function [Fig,cb,data] = spectrogram_quickplot(x,fs,tres,fres,P_dBm_lims,SET_OUT_OF_LIMIT_NAN)
%[Fig,cb,data] = misc.plots.spectrogram_quickplot(x,fs,tres,fres,[P_dBm_lims=[-inf,inf]],[SET_OUT_OF_LIMIT_NAN=false])
%
% If instance of mysp.timefrequencybase is given instead of fs, parameters
% fs, t0 and fc are used to place the spectrogram accordingly.
%
% Output 'data' contains the z axis (P_dBm) and timefrequencybases for x,y.
%
% See also mysp.timefrequencybase.

    if nargin < 6
        SET_OUT_OF_LIMIT_NAN = [];
    end
    if isempty(SET_OUT_OF_LIMIT_NAN)
        SET_OUT_OF_LIMIT_NAN = false;
    end

    if nargin < 5
        P_dBm_lims = [];
    end
    P_dBm_lims = misc.parse_limits(P_dBm_lims,[-inf inf],'name','P_dBm_lims','verbose',true);

    if isa(fs,'mysp.timefrequencybase')
        tf = fs;
        if size(x,1) ~= tf.N
            warning('tf given: size of x does not fit tf.N.');
        end
        fs = tf.fs;
        fc = tf.fc;
        t0 = tf.t0;
    else
        fc = 0;
        t0 = 0;
    end

    [P_dBmperHz,TTspec,FFspec] = mysp.get_spectrogram(x,fs,tres,fres);
    TTspec = TTspec + t0;
    FFspec = FFspec + fc;

    P_dBm = P_dBmperHz + 10*log10(abs(fres));

    P_dBm_minmax = [ min(P_dBm(~isinf(P_dBm)),[],'all','omitnan') , ...
                     max(P_dBm(~isinf(P_dBm)),[],'all','omitnan') ];
    P_dBm_lims(isinf(P_dBm_lims)) = P_dBm_minmax(isinf(P_dBm_lims));

    if SET_OUT_OF_LIMIT_NAN
        P_dBm(P_dBm > max(P_dBm_lims)) = nan;
        P_dBm(P_dBm < min(P_dBm_lims)) = nan;
    else
        P_dBm(P_dBm > max(P_dBm_lims)) = max(P_dBm_lims);
        P_dBm(P_dBm < min(P_dBm_lims)) = min(P_dBm_lims);
    end

    Fig = gcf;
    surf(TTspec/1e-3,FFspec/1e6,P_dBm,'LineStyle','none');
    view(2);
    xlabel('t (ms)');
    ylabel('f (MHz)');
%     cb = colorbar;
%     cb.Label.String = 'P (dBm)';
    zlim(P_dBm_lims);
%     cb.Limits = P_dBm_lims;
    title('power spectrum');
cb = [];
    if nargout > 2
        data.P_dBm = P_dBm;

        data.tf.time = mysp.timefrequencybase(size(TTspec,2),1/diff(TTspec(1,1:2)));
        data.tf.time.fc = fc;
        data.tf.time.t0 = t0;

        N_ff = size(FFspec,1);
        data.tf.freq = mysp.timefrequencybase(N_ff,N_ff*diff(FFspec(1:2,1)));
        data.tf.freq.fc = fc;
        data.tf.freq.t0 = t0;
    end

end