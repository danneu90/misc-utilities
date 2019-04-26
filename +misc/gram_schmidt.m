function H_new = gram_schmidt(H_raw,H_old)
%H_new = misc.gram_schmidt(H_raw,H_old)
%
%Builds an orthonormal base H_new from column vectors of H_raw. If H_old is
%given, it adds new vectors to this old basis (optional). In this case, the
%user must take care of the orthonormality of H_old.

    if nargin < 2
        H_old = [];
    end

    if size(H_raw,2) > 1
        % recurse all new vectors
        H_old = misc.gram_schmidt(H_raw(:,1:end-1),H_old);
        H_raw = H_raw(:,end);
    end

    % normalize
    H_raw = H_raw/sqrt(H_raw'*H_raw);

    if isempty(H_old)
        H_new = H_raw;
    else

        assert(size(H_old,1) == size(H_raw,1),'H_new must contain as many rows as H_old.');

        % normalize
        H_old = H_old./sqrt(sum(abs(H_old).^2));

        assert(rank([H_old,H_raw]) > rank(H_old),'H_new bears no new information, it lies in span(H_old).');

        h_new_raw = H_raw - H_old*(H_old'*H_raw);

        h_new = h_new_raw/sqrt(h_new_raw'*h_new_raw);

        H_new = [H_old , h_new];

    end

    if 1 - rcond(H_new'*H_new) > 1e-3
        warning('rcond(H_new''*H_new) differs significantly from 1. Bad orthogonalization.');
    end

end



%% EXAMPLE
%  
% base_raw = complex(randn(10,5),randn(10,5));
% 
% tt = (-5:01:10).';
% base_raw = tt.^(0:3);
% 
% base_orth = misc.gram_schmidt(base_raw);
% 
% norm(base_orth'*base_orth - eye(size(base_orth,2)))
% 
% 
% theta_orth = [1 2 3 4].';
% theta_raw = (base_orth'*base_raw)\theta_orth;
% 
% 
% figure;
% plot(tt,base_orth*theta_orth);
% hold on;
% plot(tt,base_raw*theta_raw);
% grid on;