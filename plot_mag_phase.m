function Fig = plot_mag_phase(varargin)
%Fig = plot_mag_phase(varargin)
%everything almost like plot
%
%replace "hold on" with
% "arrayfun(@(x) set(x,'NextPlot','add'),findall(gcf,'type','axes'))"

    Hvarargin = cell(1,4);
    Hvarargin(1:numel(varargin)) = varargin;
    varargin = Hvarargin;

    if ~isa(varargin{1},'matlab.ui.Figure')
        varargin = [{gcf},varargin];
    end

    if isempty(varargin{3}) || ischar(varargin{3})
        varargin = [varargin(1) , {1:numel(varargin{2})} , varargin(2:end)];
    end

    Fig = varargin{1};
    x = varargin{2};
    y = varargin{3};
    varargin = varargin(4:end);
    varargin = varargin(cellfun(@(x) ~isempty(x),varargin));

    figure(Fig);
    sp(1) = subplot(2,1,1);
    plot(x,20*log10(abs(y)),varargin{:});
    grid on;
    title('mag');

    sp(2) = subplot(2,1,2);
    plot(x,unwrap(angle(y)),varargin{:});
    grid on;
    title('ang');

    linkaxes(sp,'x');

end