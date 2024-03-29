function [theta,D,XX,LSerr] = estimate_LS_polynom_parameters(x,y,order,w)
%[theta,D,XX,LSerr] = misc.estimate_LS_polynom_parameters(x,y,order,w)
%
%Tries to fit a polynomial of 'order' to the real valued signal y(x) with
%weight w (optional).
%
%Output:
%   theta	...	polynomial coefficients.
%   D       ... Differentiation operator.
%   XX      ... Function to restore x base for theta.
%   LSerr   ... LS error for orders up to the given one.

%% prepare

    if nargin < 3
        order = 2;
    else
        assert(order == uint64(order),'order must be integer.');
    end
    if nargin < 4
        w = [];
    end

    if isempty(x)
        x = (0:size(y,1)-1).';
    end

    if isempty(w)
        assert(isequal(size(x),size(y)),'x and y must be of same size.');
    else
        assert(isequal(size(x),size(y),size(w)),'x, y and w must be of same size.');
    end

    assert(size(x,2) == 1,'x must be (one-dimensional) column vector.');

%% start

    x = double(x);
    y = double(y);

    if any(isnan(y))
        warning('y contains %.2f %% NaNs. Weights of NaN values will be set to zero.',100*sum(isnan(y))/numel(y));
        if isempty(w)
            w = ones(size(y));
        end
        w(isnan(y)) = 0;
        y(isnan(y)) = 0;
    end

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

    if isempty(w)
        % regular LS
        theta_orth = H_orth\y_cond;
    else
        % weighted LS
        W = sparse(1:numel(w),1:numel(w),double(w)/max(abs(double(w))));
        theta_orth = (H_orth'*W*H_orth)\H_orth'*W*y_cond;
    end

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

