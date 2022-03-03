classdef param

    properties
        name (1,:);
        values (:,1);
        secondary (:,1) pspace.param; % must be of same size as parent parameter; pspace.pspace.set_target_parameters will also set all secondary parameters
    end

    properties (Dependent = true, SetAccess = private)
        N;
    end

    properties (Constant = true, Hidden = true)
        char_forbidden = {' ','/','\'};
    end

    methods
        function obj = param(name,values)
            obj.name = name;
            if nargin > 1
                obj.values = values;
            end
        end

        function objext = extract(obj,idx)
            objext = pspace.param(obj.name,obj.values(idx));
        end

        function obj = sort(obj)
            try
                tmp = cell2mat(obj.values);
                [~,idx] = sort(tmp);
                obj.values = obj.values(idx);
            catch ME
                warning("Could not sort parameter '%'. Leaving it as is.",obj.name);
            end
        end

        function obj = shuffle(obj)
            obj.values = obj.values(randperm(obj.N));
        end

        function obj = flip(obj)
            obj.values = flip(obj.values);
        end

        function N = get.N(obj)
            N = numel(obj.values);
        end

        function obj = set.name(obj,name)
            assert(isStringScalar(name) || ischar(name),'Parameter name must be string.');
            name = string(name);
            assert(~name.contains(obj.char_forbidden),'Parameter name must not contain any of these characters: %s',sprintf("'%s' ",obj.char_forbidden{:}).strip)
            obj.name = name;
        end

        function obj = set.values(obj,values)
            if ~iscell(values)
                values = num2cell(values);
            end
            obj.values = values;
        end

        function values = get.values(obj)
            values = obj.values;
            if numel(values) == 1 % if only one element -> no problem, just return content
                values = values{1};
            else % try to return matrix instead of cell array
                try
                    values = cell2mat(obj.values);
                catch ME
                    % if it does not work -> warning only if not the
                    % expected error
                    if ~ismember(ME.identifier,{'MATLAB:cell2mat:MixedDataTypes','MATLAB:cell2mat:UnsupportedCellContent'})
                        warning(ME.identifier,'Could not convert values to array: "%s"',ME.message);
                    end
                end
            end
        end

        function secondary = get.secondary(obj)
            assert(all([obj.secondary.N] == obj.N),'Size of secondary parameters do not fit primary paramters. Must have the same number of elements.');
            secondary = obj.secondary;
        end

    end

end