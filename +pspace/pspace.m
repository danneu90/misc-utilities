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

        struct;
    end

    methods

        function obj = pspace(varargin)
            if isa(varargin,'pspace.pspace') && numel(varargin) == 1
                obj = varargin;
            else
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
        end

        function disp(obj)
            builtin('disp',obj);
            if numel(obj) == 1 && obj.Ncomb == 1
                fprintf('\n');
                for ii = 1:obj.Nparam
                    fprintf('\b%s =\n',obj.names(ii))
                    disp(obj.param_list(ii).values{1});
                end

            end
        end

        function [psp,hash] = get_elem(obj,ind)
            sz = obj.Nvalues;
            sub = cell(numel(sz),1);
            [sub{:}] = ind2sub(sz,ind);
            psp = repmat(obj,size(ind));
            hash = strings(size(ind));
            for jj = 1:numel(psp)
                for ii = 1:psp(jj).Nparam
                    psp(jj).param_list(ii).values = psp(jj).param_list(ii).values(sub{ii}(jj));
                end
                if nargout > 1
                    hash(jj) = psp(jj).hash();
                end
            end
        end

        function [sub] = find_values(obj,varargin)
        %[sub] = obj.find_values(param0,values0,param1,values1,...)
        %
        % Finds subscripts of certain parameter values in parameter
        % space.
        % Same input as when constructing param space. If valuesx is
        % empty, all existing parameters are returned. (Same as
        % omitting paramx.)
            ps = pspace.pspace(varargin{:});
            sub = cell(obj.Nparam,1);
            for ii = 1:obj.Nparam
                sub{ii} = (1:obj.Nvalues(ii)).';
            end
            for ii = 1:ps.Nparam
                try
                    [prm,idx_param] = obj.find_param(ps.names(ii));
                catch ME
                    warning(ME.message);
                    continue;
                end
                if ps.param_list(ii).N ~= 0 % leave all selected if parameter list empty
                    sub{idx_param} = nan(prm.N,1);
                    for jj = 1:ps.param_list(ii).N
                        idx = find(cellfun(@(x) isequal(x,ps.param_list(ii).values{jj}),prm.values));
                        if ~isempty(idx)
                            sub{idx_param}(jj) = idx;
                        end
                    end
                    sub{idx_param}(isnan(sub{idx_param})) = [];
                end
%                 sub{idx_param} = find(ismember(prm.values,ps.param_list(ii).values));
            end
        end

        function pspace_exp = expand(obj)
            if obj.Ncomb == 1
                pspace_exp = obj;
            else
                idx_prm = find([obj.param_list.N] > 1,1,'first');
                prm = obj.param_list(idx_prm);
                pspace_exp = pspace.pspace.empty();
                for ii = 1:prm.N
                    pspace_tmp = obj;
                    pspace_tmp.param_list(idx_prm).values = prm.values(ii);
                    pspace_exp = cat(idx_prm,pspace_exp,pspace_tmp.expand());
                end
            end
        end

        function [param,idx_param] = find_param(obj,name)
            idx_param = find(ismember(obj.names,name));
            param = obj.param_list(idx_param);
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

        function strct = get.struct(obj)
            strct = struct();
            for ii = 1:obj.Nparam
                strct.(obj.param_list(ii).name) = obj.param_list(ii);
            end
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

        function [hash,pspace_exp] = hash(obj)
            if numel(obj) == 1
                [str,pspace_exp] = obj.set_target_parameters();
            else
                str = cell(size(obj));
                for ii = 1:numel(str)
                    assert(obj(ii).Ncomb == 1,'Can only hash arrays if already expanded.');
                    str{ii} = obj(ii).set_target_parameters();
                end
                pspace_exp = obj;
                str = cell2mat(str);
            end
            hash = strings(size(str));
            for ii = 1:numel(str)
                hash(ii) = misc.DataHash(str(ii));
            end
        end

        function [pspc,sub] = find_hash(obj,hash)
            if numel(hash) == 1 && isa(hash,'pspace.pspace') && hash.Ncomb == 1
                hash = hash.hash();
            end
            [hash_all,pspace_exp] = obj.hash();
            sz = size(hash_all);
            sub = cell(numel(sz),1);
            [sub{:}] = ind2sub(sz,find(hash_all == hash));
            pspc = pspace_exp(sub{:});
        end

        function [target,pspace_exp] = set_target_parameters(obj,target)
            if nargin < 2
                target = struct();
            end
            if obj.Ncomb > 1
                pspace_exp = obj.expand();
            else
                pspace_exp = obj;
            end
            sz = size(pspace_exp);
            target = repmat(target,sz);
            for ii = 1:numel(pspace_exp)
                for jj = 1:pspace_exp(ii).Nparam
                    prm = pspace_exp(ii).param_list(jj);
                    target(ii).(prm.name) = prm.values(1);
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
