% MOVE THIS FILE TO PARENT DIRECTORY FOR CLASS TESTING

clc;

pb = percent_bar('selftime',1,'cmdline',1,'warn_high_selftime',0.1);

pb.init_loop();

N = 100;
for ii = 0:N
    
    pause(0.01);
    
    percent = ii/N;
    pb.iteration_finished(percent);
    
end

%%

clc;

pb = percent_bar();

pb.init_loop();

N = 100;
for ii = 0:N
    
    pause(0.01);
    
    percent = ii/N;
    pb.iteration_finished(percent);
    
end





