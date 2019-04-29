function [theta,D,XX,LSerr] = estimate_LS_polynom_parameters(x,y,order,w)
%[theta,D,XX,LSerr] = misc.estimate_LS_polynom_parameters(x,y,order,w)
%% prepare

    if nargin < 3
        order = 2;
    else
        assert(order == uint64(order),'order must be integer.');
    end
    if nargin < 4
        w = [];
    end

    if isempty(w)
        w = ones(size(x));
    end

    assert(size(x,2) == 1,'x must be (one-dimensional) column vector.');
    assert(isequal(size(x),size(y),size(w)),'x, y and w must be of same size.');

%% start

    x = double(x);
    y = double(y);

    W = diag(double(w)/max(abs(double(w))));

    % 'conditioning' of x axis
    conditioner_x = max(abs(x));
    x_cond = x/conditioner_x;

    % 'conditioning' of y data
    conditioner_y = max(abs(y));
    y_cond = y/conditioner_y;

    % timing Vandermonde matrix of order
    XX = @(x) x.^(0:order);

    % get bases
    H_raw = XX(x_cond);
    H_orth = misc.gram_schmidt(H_raw);

    % weighted LS
    theta_orth = (H_orth'*W*H_orth)\H_orth'*W*y_cond;

    % base transformation
    theta_cond = (H_orth'*H_raw)\theta_orth;

    % 'deconditioning'
    theta = theta_cond./XX(conditioner_x).' * conditioner_y;

    % differentiation operator
    D = diag(1:order,1);

    % calculate LS error for orders up to given one
    if nargout > 3
        warning('LS error calculation for each order up to given one is time consuming. Consider removing output LSerr.');
        LSerr = nan(size(theta));
        for ii = 1:numel(theta)-1
            order_lserr = ii - 1;
            [theta_lserr,~,XX_lserr] = misc.estimate_LS_polynom_parameters(x,y,order_lserr,w);
            H_lserr = XX_lserr(x);

            y_lserr = H_lserr*theta_lserr;
            lserr = y - y_lserr;
            LSerr(ii) = norm(lserr);
        end
        H_lserr = XX(x);
        y_lserr = H_lserr*theta;
        lserr = y - y_lserr;
        LSerr(end) = norm(lserr);
    end

end

