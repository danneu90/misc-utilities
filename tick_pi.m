function [tick_list,ticklabels_list] = tick_pi(pi_multiple,limits)
%[tick_list_deg,ticklabels_list] = tick_pi(pi_multiple,limits_deg)

    assert(pi_multiple ~= 0 && ~isnan(pi_multiple) && ~ isinf(pi_multiple),'pi_multiple must be greater than zero.');

    if ~strcmpi(get(gca,'TickLabelInterpreter'),'latex')
        warning('Current axes does not have ''latex'' as ''TickLabelInterpreter''. This is required.');
    end
    
    limits_deg = sort(limits)/pi*180;
    pi_multiple = abs(pi_multiple);

    if pi_multiple < 1 % fractional
        tick_granularity_deg = 180/round(1/pi_multiple);
    else % multiple
        tick_granularity_deg = 180*round(pi_multiple);
    end

    tick_list_deg = tick_granularity_deg*ceil(limits_deg(1)/tick_granularity_deg):tick_granularity_deg:limits_deg(2);
    tick_list = tick_list_deg/180*pi;
    
%     if pi_multiple < 1 % fractional
%         denominator = round(1/pi_multiple)*ones(size(tick_list_deg));
%     else % multiple
%         denominator = ones(size(tick_list_deg));
%     end
%     numerator = tick_list_deg/180.*denominator;
    
    [numerator,denominator] = rat(tick_list_deg/180);
    [numerator,denominator] = rat(numerator./denominator);
    
    ticklabels_list = sprintf_fraction(numerator,denominator);
    
%     if pi_multiple < 1
%         pi_fractional = round(1/pi_multiple);
%         [tick_list_deg,ticklabels_list] = tick_pi_fractional(pi_fractional,limits_deg);
%     else
%         pi_multiple = round(pi_multiple);
%         [tick_list_deg,ticklabels_list] = tick_pi_multiple(pi_multiple,limits_deg);
%     end

end

function [string_list] = sprintf_fraction(numerator,denominator)
%%
    string_list = cell(size(numerator));
    for ii = 1:numel(numerator)
        
        num = numerator(ii);
        den = denominator(ii);
        
        if den == 1
            Hstring = sprintf('%d\\pi',num);
        else
            Hstring = sprintf('%d\\frac{\\pi}{%d}',num,den);
        end
        
        if num == -1
            Hstring(2) = ''; % remove one after minus
        elseif num == 0
            Hstring = '0'; % set zero
        elseif num == 1
            Hstring(1) = ''; % remove one
        end
        string_list{ii} = ['$',Hstring,'$'];
    end

end



% function [tick_list_deg,ticklabels_list] = tick_pi_multiple(pi_multiple,limits_deg)
% %%
% % clc;
% % limits_deg = ylims;
% % pi_fractional = 6;
% % 
% %     limits_deg = sort(limits_deg);
% %     pi_multiple = abs(round(pi_multiple));
% %     
% %     assert(pi_multiple ~= 0,'pi_multiple must be integer greater zero.');
% % 
% %     
%     
%     tick_granularity_deg = 180*pi_multiple;
% 
%     tick_list_deg = tick_granularity_deg*ceil(limits_deg(1)/tick_granularity_deg):tick_granularity_deg:limits_deg(2);
% 
%     ticklabels_list = arrayfun(@(x) sprintf('$%d\\pi$',x/180),tick_list_deg,'UniformOutput',false);
% 
%     if any(pi_multiple*tick_list_deg/180 == -1)
%         ticklabels_list{pi_multiple*tick_list_deg/180 == -1}(3) = '';
%     end
%     if any(pi_multiple*tick_list_deg/180 == 0)
%         ticklabels_list{pi_multiple*tick_list_deg/180 == 0} = '0';
%     end
%     if any(pi_multiple*tick_list_deg/180 == 1)
%         ticklabels_list{pi_multiple*tick_list_deg/180 == 1}(2) = '';
%     end
%     
% end
% 
% function [tick_list_deg,ticklabels_list] = tick_pi_fractional(pi_fractional,limits_deg)
% %%
% % clc;
% % limits_deg = ylims;
% % pi_fractional = 6;
% 
% %     if ~strcmpi(get(gca,'TickLabelInterpreter'),'latex')
% %         warning('Current axes does not have ''latex'' as ''TickLabelInterpreter''. This is required.');
% %     end
% % 
% %     limits_deg = sort(limits_deg);
% %     pi_fractional = abs(round(pi_fractional));
% %     
% %     assert(pi_fractional ~= 0,'pi_fractional must be integer greater zero.');
% 
%     tick_granularity_deg = 180/pi_fractional;
% 
%     tick_list_deg = tick_granularity_deg*ceil(limits_deg(1)/tick_granularity_deg):tick_granularity_deg:limits_deg(2);
% 
%     ticklabels_list = arrayfun(@(x) sprintf('$%d\\frac{\\pi}{%d}$',pi_fractional*x/180,pi_fractional),tick_list_deg,'UniformOutput',false);
% 
%     if any(pi_fractional*tick_list_deg/180 == -1)
%         ticklabels_list{pi_fractional*tick_list_deg/180 == -1}(3) = '';
%     end
%     if any(pi_fractional*tick_list_deg/180 == 0)
%         ticklabels_list{pi_fractional*tick_list_deg/180 == 0} = '0';
%     end
%     if any(pi_fractional*tick_list_deg/180 == 1)
%         ticklabels_list{pi_fractional*tick_list_deg/180 == 1}(2) = '';
%     end
%     
% end