classdef pspace

    properties
        param_list (:,1) pspace.param;
    end

    properties (Dependent = true)
        names (:,1) string;
    end

    properties (Dependent = true, SetAccess = private)
        Nvalues;
        Nparam;
        Ncomb;
    end

    methods

        function obj = pspace(varargin)
            while ~isempty(varargin)
                if isa(varargin{1},'pspace.param')
                    obj = obj.add_param(varargin{1});
                    varargin(1) = [];
                else
                    assert(numel(varargin) >= 2,'Name and values must come in pairs.');
                    obj = obj.add_param(varargin{1},varargin{2});
                    varargin(1:2) = [];
                end
            end
        end

        function pspace_lin = linearize(obj)
            if obj.Ncomb == 1
                pspace_lin = obj;
            else
                idx_prm = find([obj.param_list.N] > 1,1,'first');
                prm = obj.param_list(idx_prm);
                pspace_lin = pspace.pspace.empty();
                for ii = 1:prm.N
                    pspace_tmp = obj;
                    pspace_tmp.param_list(idx_prm).values = prm.values(ii);
                    pspace_lin = [pspace_lin;pspace_tmp.linearize()];
                end
            end
        end

        function param = find_param(obj,name)
            param = obj.param_list(ismember(obj.names,name));
            if isempty(param)
                str_err = sprintf("Could not fine '%s'.",name);
                is_similar = contains(lower(obj.names),lower(name));
                if any(is_similar)
                    str_err = str_err.append(" Did you mean ");
                    str_err = str_err.append(sprintf("'%s' ",obj.names(is_similar)).strip);
                    str_err = str_err.append("?");
                end
                error(str_err);
            end
        end

        function obj = add_param(obj,name,values)
            if nargin == 2 && isa(name,'pspace.param')
                param = name;
            else
                param = pspace.param(name,values);
            end
            assert(~ismember(param.name,obj.names),'Parameter ''%s'' already exists.',param.name);
            obj.param_list(end+1) = param;
        end

        function Ncomb = get.Ncomb(obj)
            Ncomb = prod(obj.Nvalues);
        end

        function Nvalues = get.Nvalues(obj)
            Nvalues = [obj.param_list.N];
        end

        function Nparam = get.Nparam(obj)
            Nparam = numel(obj.param_list);
        end

        function obj = set.names(obj,names)
            assert(numel(names) == obj.Nparam,'%u names required.',obj.Nparam);
            for ii = 1:obj.Nparam
                obj.param_list(ii).name = names(ii);
            end
        end

        function names = get.names(obj)
            if obj.Nparam == 0
                names = strings(0);
            else
                names = [obj.param_list.name];
            end
        end

        function [hash,pspace_lin] = hash(obj)
            [str,pspace_lin] = obj.set_target_parameters();
            hash = strings(numel(str),1);
            for ii = 1:numel(str)
                hash(ii) = misc.DataHash(str(ii));
            end
        end

        function pspace = find_hash(obj,hash)
            if numel(hash) == 1 && isa(hash,'pspace.pspace') && hash.Ncomb == 1
                hash = hash.hash();
            end
            [hash_all,pspace_lin] = obj.hash();
            pspace = pspace_lin(ismember(hash_all,hash));
        end

        function [target,pspace_lin] = set_target_parameters(obj,target)
            if nargin < 2
                target = struct();
            end
            pspace_lin = obj.linearize();
            target = repmat(target,[numel(pspace_lin),1]);
            for ii = 1:numel(pspace_lin)
                for jj = 1:pspace_lin(ii).Nparam
                    prm = pspace_lin(ii).param_list(jj);
                    target(ii).(prm.name) = prm.values;
                end
            end
        end

        function obj = sort(obj)
            for ii = 1:numel(obj)
                [~,idx_sort] = sort(obj(ii).names);
                obj(ii).param_list = obj(ii).param_list(idx_sort);
            end
        end

    end
    
end
