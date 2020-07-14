function [filename_base,filename_data,filename_graphic] = store_figure_data(Fig,filename_base)
%[filename_base,filename_data,filename_graphic] = misc.plots.store_figure_data(Fig,filename_base)

    filename_base_def = datestr(now,'yyyymmddTHHMMSSFFF');

    if nargin == 1
        if isa(Fig,'matlab.ui.Figure')
            filename_base = '';
        elseif ischar(Fig)
            filename_base = Fig;
            Fig = gcf;
        end
    elseif nargin == 0
        Fig = gcf;
        filename_base = '';
    else
        if isa(filename_base,'matlab.ui.Figure') && ischar(Fig)
            Helper = filename_base;
            filename_base = Fig;
            Fig = Helper;
        end
        assert(isa(Fig,'matlab.ui.Figure') && ischar(filename_base),'Fig must be of class ''matlab.ui.Figure'', filename_base must be char array.');
    end
    %%%

    if isempty(filename_base)
        filename_base = ['.',filesep,filename_base_def];
    elseif exist(filename_base,'dir')
        [location,filename_base,suffix] = fileparts(filename_base);
        if isempty(location)
            location = '.';
        else
            location = strrep(location,'/',filesep);
            location = strrep(location,'\',filesep);
        end
        filename_base = [location,filesep,filename_base,filesep,filename_base_def];
    else
        [location,filename_base,suffix] = fileparts(filename_base);
        if isempty(location)
            location = '.';
        else
            location = strrep(location,'/',filesep);
            location = strrep(location,'\',filesep);
        end
        filename_base = [location,filesep,filename_base];
    end

    if exist([filename_base,'.png'],'file') || exist([filename_base,'.fig'],'file')
%         filename_base = [filename_base,'_new'];
        warning('Files exist. Will be replaced.');
    end

    filename_data = [filename_base,'.fig'];
    filename_graphic = [filename_base,'.png'];

    print(Fig,filename_graphic,'-dpng','-r400');
    savefig(Fig,filename_data,'compact');

end

