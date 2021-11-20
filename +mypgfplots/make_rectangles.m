function [x,y,z,str_tex_coord] = make_rectangles(Xin,Yin,Zin,DISCARD_NAN)
%[x,y,z] = mypgfplots.make_rectangles(Xin,Yin,Zin,DISCARD_NAN)

%%
VERBOSE = false;

    if nargin < 4
        DISCARD_NAN = [];
    end
    if isempty(DISCARD_NAN)
        DISCARD_NAN = true;
    end

    % [Xin,Yin] = ndgrid(0:3,0:4);
    % Zin = Xin.^2 + Yin.^2;
    % Zin(Zin > 10) = nan;

    assert(isequal(size(Xin),size(Zin)) && isequal(size(Yin),size(Zin)),'All inputs must be of equal size.');
    assert(~any(diff(Xin(1,:))) && ~any(diff(Yin(:,1))),'Xin and Yin must be shaped according to ndgrid output.');




    X = cat(3,Xin(1:end-1,1:end-1),Xin(  2:end,1:end-1),Xin(  2:end,1:end-1),Xin(1:end-1,1:end-1));
    Y = cat(3,Yin(1:end-1,1:end-1),Yin(1:end-1,1:end-1),Yin(1:end-1,  2:end),Yin(1:end-1,  2:end));
    Z = cat(3,Zin(1:end-1,1:end-1),Zin(  2:end,1:end-1),Zin(  2:end,  2:end),Zin(1:end-1,  2:end));

    if DISCARD_NAN
        X(repmat(any(isnan(Z),3),[1 1 4])) = nan;
        Y(repmat(any(isnan(Z),3),[1 1 4])) = nan;
        Z(repmat(any(isnan(Z),3),[1 1 4])) = nan;
    end


    if VERBOSE
        tic
    end
    x = reshape(permute(X,[3,2,1]),[],1);
    y = reshape(permute(Y,[3,2,1]),[],1);
    z = reshape(permute(Z,[3,2,1]),[],1);
    if VERBOSE
        toc
    end

    if DISCARD_NAN
        x(isnan(x)) = [];
        y(isnan(y)) = [];
        z(isnan(z)) = [];
    end

    if VERBOSE
        figure;
        surf(Xin,Yin,Zin);
        hold on;
        for ii = 1:4:numel(x)
            surf(reshape(x(ii:ii+3),[2 2]),reshape(y(ii:ii+3),[2 2]),reshape(z(ii:ii+3),[2 2]));
        end
    end

    if nargout > 3
        str_tex_coord = strings(size(Xin));
        for ii = 1:numel(str_tex_coord)
            str_tex_tmp = string([Xin(ii),Yin(ii),Zin(ii)]);
            str_tex_tmp(ismissing(str_tex_tmp)) = "0";
            str_tex_coord(ii) = "(" + str_tex_tmp.join(',') + ")";
        end
        str_tex_coord = str_tex_coord.';
        str_tex_coord = str_tex_coord.join(' ');
        str_tex_coord = str_tex_coord.join([newline newline]);
    end


end