function [Fig,cb] = spectrogram_quickplot(x,fs,tres,fres,P_dBm_lims)
%[Fig,cb] = misc.plots.spectrogram_quickplot(x,fs,tres,fres,[P_dBm_lims=[-inf,inf]])

    if nargin < 5
        P_dBm_lims = [];
    end
    P_dBm_lims = misc.parse_limits(P_dBm_lims,[-inf inf],'name','P_dBm_lims','verbose',true);


    [P_dBmperHz,TTspec,FFspec] = mysp.get_spectrogram(x,fs,tres,fres);

    P_dBm = P_dBmperHz + 10*log10(abs(fres));

    P_dBm_minmax = [min(P_dBm(:)) , max(P_dBm(:))];
    P_dBm_lims(isinf(P_dBm_lims)) = P_dBm_minmax(isinf(P_dBm_lims));

    P_dBm(P_dBm > max(P_dBm_lims)) = nan;
    P_dBm(P_dBm < min(P_dBm_lims)) = nan;

    Fig = figure;
    surf(TTspec/1e-3,FFspec/1e6,P_dBm,'LineStyle','none');
    view(2);
    xlabel('t (ms)');
    ylabel('f (MHz)');
    cb = colorbar;
    cb.Label.String = 'P (dBm)';
    zlim(P_dBm_lims);
    cb.Limits = P_dBm_lims;
    title('power spectrum');

end