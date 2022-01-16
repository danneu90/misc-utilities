function tab = tabkey(varargin)
%tab = misc.tabkey([P1,P2,...,Pn])
%
% Returns tabular (sprintf('\t') or char(9)). Higher dimensional array if specified so.
    if nargin < 1
        varargin = {1};
    end
    tab = repmat(sprintf('\t'),varargin{:});
end