function [dphase_dx , x_diff] = diff_phase(phase,x)
%[dphase_dx , x_diff] = misc.diff_phase(phase,x)

    if nargin < 2
        x = [];
    end
    assert(~isempty(phase) || ~isempty(x),'at least one argument must be non-empty');
    if isempty(x) && ~isempty(phase)
        x = 0:size(phase,1)-1;
    end
    if isempty(phase) && ~isempty(x)
        phase = zeros(size(x));
    end

    x = x(:);
    assert(numel(x) == size(phase,1),'x data does not fit phase data');

    dphase = diff(double(phase),[],1);

    dphase(dphase<=-pi) = dphase(dphase<=-pi) + 2*pi;
    dphase(dphase>pi) = dphase(dphase>pi) - 2*pi;

    dx = diff(x,[],1);

    dphase_dx = dphase./dx;

    x_diff = x(1:end-1,:) + dx/2;

end