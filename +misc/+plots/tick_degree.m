function [tick_list_deg] = tick_degree(tick_granularity_deg,limits_deg)
%[tick_list_deg] = misc.plots.tick_degree(tick_granularity_deg,limits_deg)

    if nargin == 1
        limits_deg = get(gca,'ylim');
    end

    limits_deg = sort(limits_deg);

    tick_list_deg = tick_granularity_deg*ceil(limits_deg(1)/tick_granularity_deg):tick_granularity_deg:limits_deg(2);

end