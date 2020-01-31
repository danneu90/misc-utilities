function [idx_good] = apply_generous_limits(z,zlim,generosity)
%[idx_good] = mypgfplots.apply_generous_limits(z,zlim,[generosity=sqrt(2)])
%
% Accepts even values outside the limits if within an l2-norm indices
% radius of size 'generosity' contains values within the limits.
% 
% z     ... One or two dimensional array.
% zlim  ... Two element vector. Element one: lower limit. Element two:
%           upper limit. Set unused limit to nan.

%%
    if nargin < 3
        generosity = [];
    end
    if isempty(generosity)
        generosity = sqrt(2);
    end

    zlim_lower = zlim(1);
    zlim_upper = zlim(2);
    if isnan(zlim_lower)
        zlim_lower = -inf;
    end
    if isnan(zlim_upper)
        zlim_upper = inf;
    end
    if zlim_upper < zlim_lower
        warning('Upper limit below lower limit.');
    end

    gen_vec = [flip(-1:-1:-abs(generosity)),0:1:abs(generosity)];

    [Xgen,Ygen] = ndgrid(gen_vec,gen_vec);

    is_in_gen = sqrt(Xgen.^2 + Ygen.^2) <= generosity;

%     Xgen(~is_in_gen) = nan;
%     Ygen(~is_in_gen) = nan;

tic
    idx_good = false(size(z));
    for ii = 1:numel(Xgen)

        if is_in_gen(ii)
            ztmp = circshift(z,[Xgen(ii),Ygen(ii)]);
            idx_good = idx_good | ( zlim_lower <= ztmp & ztmp <= zlim_upper);
        end
        
    end
toc
end