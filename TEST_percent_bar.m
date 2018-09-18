clc;

pb = percent_bar('selftime',1, ...
                 'cmdline',1, ...
                 'warn_high_selftime',0.1, ...
                 'profiling_on',true);

pb.init_loop();

N = 100;
for ii = 0:N
    
    pause(0.05*ii/N);
    
    percent = ii/N;
    pb.iteration_finished(percent);
    
end

pb.view_profiling

%%

clc;

pb = percent_bar();

pb.init_loop();

N = 100;
for ii = 0:N
    
    pause(0.1);
    
    percent = ii/N;
    pb.iteration_finished(percent);
    
end





