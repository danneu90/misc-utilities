function [Fig,Sparam] = s2p_quickplot(fn)
%[Fig,Sparam] = misc.plots.s2p_quickplot(fn)

    Sparam = sparameters(fn);

    ff = Sparam.Frequencies;

    S = Sparam.Parameters;

    leg = {'S_{11}','S_{21}','S_{22}','S_{12}'};

    Fig = figure;
    sp(1) = subplot(2,1,1);
    plot(ff/1e6,20*log10(abs(squeeze(S(1,1,:)))));
    hold on;
    plot(ff/1e6,20*log10(abs(squeeze(S(2,1,:)))));
    plot(ff/1e6,20*log10(abs(squeeze(S(2,2,:)))));
    plot(ff/1e6,20*log10(abs(squeeze(S(1,2,:)))));
    grid on;
    legend(leg);
    xlabel('f (MHz)');
    ylabel('|S_{xx}| (dB)');

    [~,ff_diff] = misc.diff_phase([],ff);

    sp(2) = subplot(2,1,2);
    plot(ff_diff/1e6,-misc.diff_phase(angle(squeeze(S(1,1,:))),ff)/(2*pi)/1e-9);
    hold on;
    plot(ff_diff/1e6,-misc.diff_phase(angle(squeeze(S(2,1,:))),ff)/(2*pi)/1e-9);
    plot(ff_diff/1e6,-misc.diff_phase(angle(squeeze(S(2,2,:))),ff)/(2*pi)/1e-9);
    plot(ff_diff/1e6,-misc.diff_phase(angle(squeeze(S(1,2,:))),ff)/(2*pi)/1e-9);
    grid on;
    legend(leg);
    xlabel('f (MHz)');
    ylabel('group delay (ns)');

    linkaxes(sp,'x');

    Fig.Children(2).Children(4).Visible = 'off';
    Fig.Children(2).Children(2).Visible = 'off';

end

