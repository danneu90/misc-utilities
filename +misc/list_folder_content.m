function filename_list = list_folder_content(location,varargin)
%filename_list = list_folder_content(location,varargin)
%Returns 'name' property of the dir(location) result with some filters
%applied. Folders '.' and '..' are always excluded. Regexps allowed.
%
% location (optional) ... Location to list. Must be folder. Default: '.';
% varargin (optional):
%   'ignore_chars'    ... Files starting with characters in this char array
%                         will be ignored. Default: '';
%   'relativepath'    ... Try to return relative path instead of absolute.
%                         If not possible, fall back to absolute.
%                         Default: false
%   'files_only'      ... Returns only files, no folders. Default: false
%   'folders_only'    ... Returns only folders, no files. Default: false
%                         Setting both files_only and folders_only true
%                         will lead to an empty filename_list.
%
% Examples:
% filename_list = misc.list_folder_content(); % Lists everything in current folder using absolute paths.
% filename_list = misc.list_folder_content('..','folders_only',1,'relativepath',1); % Lists all folders in parent folder using relative paths.
% filename_list = misc.list_folder_content('ignore_chars','.#'); % Lists current folder ignoring all files starting with '.' or '#'.

%% defaults

    ignore_chars_default = '';
    relativepath_default = false;
    files_only_default   = false;
    folders_only_default = false;

%% parse input

    if nargin == 0
        location = [];
    end

    if numel(varargin) > 0 && mod(numel(varargin),2)
        varargin = [{location} varargin];
        location = [];
    end

    p = inputParser;

    p.addParameter('ignore_chars'   ,ignore_chars_default   ,@(x) validateattributes(x,{'char','string'},{'scalartext'}));
    p.addParameter('relativepath'   ,relativepath_default   ,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
    p.addParameter('files_only'     ,files_only_default     ,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
    p.addParameter('folders_only'   ,folders_only_default   ,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));

    p.parse(varargin{:});

    ignore_chars = p.Results.ignore_chars;
    relativepath = boolean(p.Results.relativepath);
    files_only = boolean(p.Results.files_only);
    folders_only = boolean(p.Results.folders_only);

%% prepare location

    if isempty(location) % empty location or '.' or '..'
        location = './';
    elseif numel(location) == 1 && strcmp(location,'.') || numel(location) == 2 && strcmp(location,'..')
        location = [location , filesep];
    end

    location = strrep(location,'\',filesep);
    location = strrep(location,'/',filesep);

    if numel(location) > 1 && strcmp(location(end-1:end),[filesep,'.']) % drop trailing period
        location(end) = [];
    end

%% check regexp

    if ~isfolder(location) % no folder -> check for regexp
        [location,regexpmask,suffix] = fileparts(location);
        regexpmask = [regexpmask,suffix];
        if isempty(location)
            location = '.';
        end
        location = [location , filesep];
    else % location was folder all along
        regexpmask = '';
        suffix = '';
    end

    if isempty(regexpmask)
        regexpmask = '*';
    end
    regexpmask = strrep(regexpmask,'.','[.]');
    regexpmask = strrep(regexpmask,'*','.*');
    regexpmask = ['^',regexpmask,'$'];

%     regexpmask = [regexpmask , suffix];

%% get location content

    assert(isfolder(location),'Folder ''%s'' not found.',location);
    dircontent = dir([location,filesep]);

    % remove '.' and '..'
    dircontent = dircontent(~ismember({dircontent.name},{'.','..'}));

%% filtering

    % filter regexp
    idx_match_regexp = cellfun(@(x) ~isempty(regexp(x,regexpmask,'once')),{dircontent.name});
    dircontent = dircontent(idx_match_regexp);

    % filter ignore character
    idx_ignore_file = cellfun(@(x) ismember(x(1),ignore_chars),{dircontent.name});
    dircontent = dircontent(~idx_ignore_file);

    % filter files only
    if files_only
        dircontent = dircontent(~[dircontent.isdir]);
    end

    % filter folders only
    if folders_only
        dircontent = dircontent([dircontent.isdir]);
    end

%% build filename list

    if ~isempty(dircontent)
        folder = dircontent(1).folder;
        if relativepath
            folder = get_relative_path(folder);
        end
        if ~strcmp(folder(end),filesep)
            folder = [folder,filesep];
        end
        filename_list = cellfun(@(x) [folder,x],{dircontent.name},'UniformOutput',false);
    else
        filename_list = {};
    end

end

function folder_relative = get_relative_path(folder)

    parts_folder = strsplit(lower([folder,filesep]),filesep);
    parts_folder = parts_folder(cellfun(@(x) ~isempty(x),parts_folder));

    parts_pwd = strsplit(lower(pwd),filesep);
    parts_pwd = parts_pwd(cellfun(@(x) ~isempty(x),parts_pwd));

    relative_possible = 0;
    while ~isempty(parts_folder) && ...
          ~isempty(parts_pwd) && ...
          strcmpi(parts_folder{1},parts_pwd{1})

        parts_folder(1) = [];
        parts_pwd(1) = [];
        relative_possible = 1;

    end

    if relative_possible
        relative_raw = [repmat({'..'},1,numel(parts_pwd)),parts_folder];
        folder_relative = ['.',filesep,strjoin(relative_raw,filesep)];
    else
        folder_relative = folder;
        warning('Cannot resolve relative path. Using absolute instead.');
    end

end