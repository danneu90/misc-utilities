function varargout = cut_to_equal_length(varargin)
%varargout = cut_to_equal_length(varargin)

    length_min = min(cellfun(@(x) size(x,1),varargin));
    varargout = cellfun(@(x) x(1:length_min,:),varargin,'UniformOutput',false);

end













