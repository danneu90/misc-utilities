function filename_list = list_folder_content(location,varargin)
%filename_list = list_folder_content(location,varargin)
% location (optional) ... Location to list. Must be folder. Default: '.';
% varargin (optional):
%   'ignore_chars'    ... Files starting with characters in this char array
%                         will be ignored. Default: '';
%   'absolutepath'    ... Return absolute path instead of relative.
%                         Default: false
%
% Examples:
% filename_list = list_folder_content('..','absolutepath',true); % Lists everything in parent folder using absolute paths.
% filename_list = list_folder_content(ignore_chars,'.#'); % Lists current folder ignoring all files starting with '.' or '#'.

    if nargin == 0
        location = [];
    end

    if numel(varargin) > 0 && mod(numel(varargin),2)
        varargin = [{location} varargin];
        location = [];
    end

    p = inputParser;

    p.addParameter('ignore_chars','',@(x) validateattributes(x,{'char','string'},{'scalartext'}));
    p.addParameter('absolutepath',false,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));

    p.parse(varargin{:});

    ignore_chars = p.Results.ignore_chars;
    absolutepath = boolean(p.Results.absolutepath);

%%
%     if nargin < 1
%         location = '.';
%     end
%     
%     if nargin < 2
%         chars_ignore = '';
%     end

    location = strrep(location,'\',filesep);
    location = strrep(location,'/',filesep);

    
    assert(~strcmp(location(1),filesep) && ~ismember(':',location),'Use relative path.');

    
    if isempty(location)
        location = '.';
    end

    if numel(location) > 1 && strcmp(location(end-1:end),[filesep,'.'])
        location = location(1:end-1);
    end
    
    if ~ismember(location(end),'/\')
        if exist(location,'file') == 7
            location = [location , filesep];
        end
    end

    [location,regexpmask,suffix] = fileparts(location);
    regexpmask = [regexpmask,suffix];
    if isempty(location)
        location = ['.'];
    end
    if ~strcmp(location(end),filesep)
        location = [location , filesep];
    end
    assert(isfolder(location),'''%s'' is not a folder.',location);

    if isempty(regexpmask)
        regexpmask = '*';
    end
    regexpmask = strrep(regexpmask,'.','[.]');
    regexpmask = strrep(regexpmask,'*','.*');
    regexpmask = ['^',regexpmask,'$'];

    dircontent = dir(location);

    idx_match_regexp = cellfun(@(x) ~isempty(regexp(x,regexpmask,'once')),{dircontent.name});

    dircontent = dircontent(idx_match_regexp);

    ignore_file = cellfun(@(x) ismember(x(1),ignore_chars),{dircontent.name});
    if absolutepath
        filename_list = cellfun(@(x) [dircontent(1).folder,filesep,x],{dircontent(~[dircontent.isdir] & ~ignore_file).name},'UniformOutput',false);        
    else
        if ~strcmp(location(1:2),['.',filesep])
            location = ['.' , filesep , location];
        end
        filename_list = cellfun(@(x) [location,x],{dircontent(~[dircontent.isdir] & ~ignore_file).name},'UniformOutput',false);
    end

end


