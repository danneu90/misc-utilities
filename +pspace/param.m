classdef param
    
    properties
        name (1,:);
        values (:,1);
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

        function obj = sort(obj)
            obj.values = sort(obj.values);
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
        
    end

end