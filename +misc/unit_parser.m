function [out_strings,isvalue] = unit_parser(values,varargin)
%[final_strings,isvalue] = misc.unit_parser(values,varargin)
%
% input:
%   values  ... Required. Can be array.
% varargin:
%   precision   ... Default 3. Format this precission.
%   unit        ... Default ''. Special units: dB, Byte.
% output:
%   out_strings ... String array formatted in the way specified.
%   isvalue     ... Logic struct showing whether special units where found.

    p = inputParser;

    p.addParameter('unit','',@(x) validateattributes(x,{'char','string'},{'scalartext'}));
    p.addParameter('precision',3,@(x) validateattributes(x,{'numeric'},{'scalar','integer','>',0}));

    p.parse(varargin{:});

    unit = char(p.Results.unit);
    precision = p.Results.precision;

    % check units
    [unit,isvalue] = check_unit(unit);

    % special cases
    if isempty(values)
        out_strings = string(['[] ',unit]);
        return;
    end
    idxnans = isnan(values);
    idxinfpos = values > 0 & isinf(values);
    idxinfneg = values < 0 & isinf(values);
    values(idxinfpos | idxinfneg) = 0;

    % analyzing
    values = double(values);
    if isvalue.byte
        range_exps = 0:8;
        range = 2.^(10*range_exps);
        prefix = ["","Ki","Mi","Gi","Ti","Pi","Ei","Zi","Yi"];

        values = ceil(values);
        values = max(values,0);
    elseif isvalue.dB
        range_exps = 0;
        range = 1;
        prefix = "";
    else
        range_exps = -8:8;
        range = 10.^(3*range_exps);
        prefix = ["y","z","a","f","p","n","u","m","","k","M","G","T","P","E","Z","Y"];
    end

    Hvalues = min(abs(values),max(range));
    Hvalues = max(Hvalues,min(range));

    if isvalue.byte
        idx = arrayfun(@(x) find(range_exps == x,1), floor(log2(Hvalues)/10));
    else
        idx = arrayfun(@(x) find(range_exps == x,1), floor(log10(Hvalues)/3));
    end

    ranges = range(idx);
    prefixes = prefix(idx);
    ranges(values == 0) = 1;
    prefixes(values == 0) = "";

    precomma = floor(log10(abs(values)./ranges) + 1);
    precomma(values == 0) = 0;
    precisions = max(precision,precomma) - precomma;

    format_strings = "%.";
    format_strings = format_strings.append(string(precisions));
    format_strings = format_strings.append("f");

    value_strings = strings(size(values));
    for ii = 1:numel(values)
        value_strings(ii) = sprintf(format_strings(ii),values(ii)/ranges(ii));
    end

    value_strings(value_strings.contains('.')) = ...
        value_strings(value_strings.contains('.')).strip('right','0').strip('right','.');

    value_strings(value_strings.endsWith('.')) = ...
        value_strings(value_strings.endsWith('.')).append('0');

    % format output
    value_strings(idxnans) = "NaN";
    value_strings(idxinfpos) = "Inf";
    value_strings(idxinfneg) = "-Inf";

    out_strings = value_strings.append(' ');
    out_strings = out_strings.append(prefixes);
    out_strings = out_strings.append(unit);

end

function [unit,isvalue] = check_unit(unit)

    isvalue.byte = false;
    isvalue.dB = false;
    if strcmpi(unit,'byte') || strcmpi(unit,'B')
        isvalue.byte = true;
        unit = 'B';
    elseif numel(unit) >= 2 && strcmpi(unit(1:2),'dB')
        isvalue.dB = true;
        unit = ['dB',unit(3:end)];
    elseif strcmpi(unit,'Hz') || strcmpi(unit,'hertz')
        unit = 'Hz';
    elseif strcmpi(unit,'V') || strcmpi(unit,'volt')
        unit = 'V';
    elseif strcmpi(unit,'A') || strcmpi(unit,'ampere') || strcmpi(unit,'amp')
        unit = 'A';
    elseif strcmpi(unit,'W') || strcmpi(unit,'watt')
        unit = 'W';
    elseif strcmpi(unit,'J') || strcmpi(unit,'joule')
        unit = 'J';
    end

end
