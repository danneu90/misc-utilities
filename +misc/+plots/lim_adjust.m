function lim_adjust(ax,dim)
%misc.plots.lim_adjust(fig/ax,[dim='xyz'])
%
% Sets specified axes limits of all given axes or all axes of given figures.

    if isa(ax,'matlab.ui.Figure')
        fig = ax;
        ax = matlab.graphics.axis.Axes.empty;
        for ii = 1:numel(fig)
            ax = [ax ; findobj( get(fig(ii),'Children'), '-depth', 1, 'type', 'axes')];
        end
    end

    if nargin < 2
        dim = 'xyz';
    end

    dim = unique(lower(char(dim)));
    assert(all(ismember(dim,'xyz')),'dim must contain only x,y,z');

    if ismember('x',dim)
        this_dim = 'xlim';
        lim_adjust_this(ax,this_dim);
    end
    if ismember('y',dim)
        this_dim = 'ylim';
        lim_adjust_this(ax,this_dim);
    end
    if ismember('z',dim)
        this_dim = 'zlim';
        lim_adjust_this(ax,this_dim);
    end

end

function lim_adjust_this(ax,this_dim)

    this_min = min(cellfun(@min,get(ax,this_dim)));
    this_max = max(cellfun(@max,get(ax,this_dim)));
    set(ax,this_dim,[this_min,this_max]);

end