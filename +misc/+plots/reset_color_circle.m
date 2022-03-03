function reset_color_circle(ax)
%misc.plots.reset_color_circle([ax=gca])
%
% Resets color circle for all given axes or all axes of given figures.

    if nargin < 1
        ax = gca;
    end

    if isa(ax,'matlab.ui.Figure')
        fig = ax;
        ax = matlab.graphics.axis.Axes.empty;
        for ii = 1:numel(fig)
            ax = [ax ; findobj( get(fig(ii),'Children'), '-depth', 1, 'type', 'axes')];
        end
    end

    for ii = 1:numel(ax)
        set(ax(ii),'ColorOrderIndex',1);
    end
    
end