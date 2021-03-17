function invA = invInf(A)
%invA = mysp.invInf(A)
%
% Like inv(A), but sets row+column zero if main diagonal value is inf
% without warning.

    assert(size(A,1) == size(A,2),'Can only do square matrices.');
    assert(numel(size(A)) == 2,'Higher dimensions not (yet) implemented.');

    N = size(A,1);

    is_inf = isinf(diag(A));
    if sum(isinf(A),'all') == sum(is_inf) % inf only on main diagonal
        A(is_inf,:) = [];
        A(:,is_inf) = [];

        invA = zeros(N);
        invA(~is_inf,~is_inf) = inv(A);
    else
        invA = inv(A);
    end
    
end