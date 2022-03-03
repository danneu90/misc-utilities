function [p,DT] = measDataTip(ax)
%[p,DT] = misc.plots.measDataTip([ax=gca])
%
% Returns the position of all DataTips by recursing into the Children of
% ax.
%
% p = [ [x0 ; y0 ; z0] , [x1 ; y1 ; z1] , ... ];
% DT datatip array

    if nargin < 1
        ax = gca;
    end

    DT = search_DataTip_child(ax);

    p = nan(3,numel(DT));
    for ii = 1:numel(DT)
        p(:,ii) = [DT(ii).X ; DT(ii).Y ; DT(ii).Z];
    end

end


function DT = search_DataTip_child(obj)

    DT = matlab.graphics.datatip.DataTip.empty;
    if numel(obj) == 1
        if isa(obj,'matlab.graphics.datatip.DataTip')
            DT = obj;
        elseif isprop(obj,'Children')
            DT = search_DataTip_child(obj.Children);
        end
    else
        for ii = 1:numel(obj)
            DT = [DT , search_DataTip_child(obj(ii))];
        end
    end

end




