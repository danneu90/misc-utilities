clc;
clear;
close all;



N = 1e3;
fs = 160e6;

t0 = 2e-6;
f0 = 1e6;

% s = mysp.signal(@(t) [cos(2*pi*f0*t) , sin(2*pi*f0*t)],N,160e6);
% s = mysp.signal(@(f) sinc(f/f0).*exp(-1i*2*pi*f*t0),N,160e6,'domain','fd','t0',1e-3);
% s = mysp.signal(@(t) double(~sign(t-t0)).*exp(-1i*2*pi*10e6*t),N,160e6);
% s = mysp.signal(randn(N,1),fs);
s = mysp.signal(exp(1i*2*pi*rand(N,1)),fs,'domain','fd');

%%

add_plot_s(s)

s.X = s.X .* hamming(s.N);
add_plot_s(s)

s.X(abs(s.ff) > 10e6) = 0;
add_plot_s(s)

%%
clc;

s.x'*s.x/s.N

s.X'*s.X/s.N


function add_plot_s(s)
    subplot(2,1,1);
    hold on;
    plot(s.tt,(s.x));
    grid on;

    subplot(2,1,2);
    hold on;
    plot(s.ff,20*log10(abs(s.X)));
    grid on;
end


