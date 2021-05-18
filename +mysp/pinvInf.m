function pinvA = pinvInf(A)
%pinvA = mysp.pinvInf(A)
%
% Like pinv(A), but sets row+column zero if main diagonal value is inf
% without warning.

    sz = size(A);
    assert(numel(sz) == 2,'Higher dimensions not (yet) implemented.');

    is_infv = false(sz(1),1);
    is_infv(1:min(sz)) = isinf(diag(A));

    is_infh = false(sz(2),1);
    is_infh(1:min(sz)) = isinf(diag(A));

    if sum(isinf(A),'all') == sum(isinf(diag(A))) % inf only on main diagonal
        A(is_infv,:) = [];
        A(:,is_infh) = [];

        pinvA = zeros(sz);
        pinvA(~is_infv,~is_infh) = pinv(A);
    else
        pinvA = pinv(A);
    end
    
end