function lims = parse_limits(lims,lims_default,varargin)
%lims = misc.parse_limits(lims,lims_default,varargin)
%
% lims      ... Limits. (Using basically lims = [min(lims), max(lims)] for output.)
% lims_default  Use if lims not stated.
%
% varargin: (all optional)
% 'name'    ... Name of limit. (char/string)
% 'maxlims' ... Apply max. allowed limits to input. (1x2 vector), default [-inf,inf]
% 'VERBOSE' ... logical, default true

    p = inputParser;
    p.addParameter('name','Limits',@(x) isStringScalar(string(x)));
    p.addParameter('maxlims',[-inf inf],@(x) isequal(size(x),[1,2]));
    p.addParameter('VERBOSE',true,@(x) islogical(logical(x)));
    p.parse(varargin{:});
    name = char(p.Results.name);
    lims_max = p.Results.maxlims;
    VERBOSE = logical(p.Results.VERBOSE);
    
    if nargin < 2
        lims_default = [];
    end
    if nargin < 3
        name = [];
    end
    if isempty(lims_default)
        lims_default = [-inf , inf];
    end
    if isempty(name)
        name = 'Limits';
    end
    
    if isempty(lims)
        lims = lims_default;
        if VERBOSE
            warning('''%s'' were set to default = [ %g , %g ].',name,min(lims_default),max(lims_default));
        end
    end
    
    lims_old = lims;
    lims = [ max(min(lims),min(lims_max)) , ...
             min(max(lims),max(lims_max))];

    if VERBOSE && ~isequal(lims,lims_old)
        warning('''%s'' exceeded max. allowable limits of [%g , %g].',name,min(lims_max),max(lims_max));
    end
    assert(lims(1) < lims(2),'''%s'' must contain at least two different values. min and max will be used as limits.',name);
    
end