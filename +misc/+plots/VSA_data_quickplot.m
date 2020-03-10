function Fig = VSA_data_quickplot(fn)
%Fig = misc.VSA_data_quickplot(fn)
%
%Example:
% fn = 'X:\DN\cc2510 trace_old from exchange 2018-05-22\recorded_SYNC_packet.mat';
% Fig = misc.VSA_data_quickplot(fn)


    [data,tt,ff] = misc.load_VSA_data(fn);

    [dphase_dt,ttdiff] = misc.diff_phase(angle(data.Y),tt);
    finst = dphase_dt/(2*pi) + data.InputCenter;

    close all;
%     Fig = figure('Units','normalized','Position',[0 0 0.5 1]);
    Fig = figure;
    sp(1) = subplot(3,1,1);
    plot(tt,20*log10(abs(data.Y)));
    grid on;

    sp(2) = subplot(3,1,2);
    plot(ttdiff,finst);
    grid on;

    sp(3) = subplot(3,1,3);
    plot(ff + data.InputCenter,20*log10(abs(fftshift(fft(data.Y))/numel(data.Y))));
    grid on;

    linkaxes(sp(1:2),'x');

end