function [theta,D,XX] = estimate_LS_polynom_parameters(x,y,order)
%[theta,D,XX] = estimate_LS_polynom_parameters(x,y,order)
%%

    if nargin == 2
        order = 2;
    end

    assert(size(x,1) == 1 || size(x,2) == 1,'x must be one-dimensional.');
    
    x = double(x(:));
    
    conditioner = x(end);

    x_cond = x/conditioner;
    
    XX = @(x) x.^(0:order);
    
    XX_cond = XX(x_cond); % timing Vandermonde matrix of order
    
    theta_cond = XX_cond\double(y);

    theta = theta_cond./conditioner.^(0:order).';

    D = diag(1:order,1); % differentiation operator

end

