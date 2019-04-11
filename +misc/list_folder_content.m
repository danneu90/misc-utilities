function filename_list = list_folder_content(location,varargin)
%filename_list = list_folder_content(location,varargin)
% location (optional) ... Location to list. Must be folder. Default: '.';
% varargin (optional):
%   'ignore_chars'    ... Files starting with characters in this char array
%                         will be ignored. Default: '';
%   'absolutepath'    ... Return absolute path instead of relative. If
%                         false, try to get relative path. If this is not
%                         possible, absolute path will be returned. (Sorry,
%                         this is due to backward compatibility.)
%                         Default: false
%   'files_only'      ... Returns only files, no folders. Default: true
%   'folders_only'    ... Returns only folders, no files. Default: false
%                         (Except for '.' and '..'.)
%                         Setting both files_only and folders_only true
%                         will lead to an empty filename_list.
%
% Examples:
% filename_list = list_folder_content('..','absolutepath',true); % Lists everything in parent folder using absolute paths.
% filename_list = list_folder_content(ignore_chars,'.#'); % Lists current folder ignoring all files starting with '.' or '#'.

%% parse input

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
    p.addParameter('files_only',true,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
    p.addParameter('folders_only',false,@(x) validateattributes(boolean(x),{'logical'},{'scalar'}));

    p.parse(varargin{:});

    ignore_chars = p.Results.ignore_chars;
    absolutepath = boolean(p.Results.absolutepath);
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

    if ~strcmp(location(end),filesep) % no trailing filesep -> no folder -> check for regexp
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

    regexpmask = [regexpmask , suffix];

%% get location content

    assert(isfolder(location),'Folder ''%s'' not found.',location);
    dircontent = dir(location);

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

    filename_list = cellfun(@(x) [dircontent(1).folder,filesep,x],{dircontent.name},'UniformOutput',false);

    if ~isempty(filename_list) && ~absolutepath % get rid of pwd in file/folder names if possible
        filename_list_old = filename_list;
        filename_list = cellfun(@(x) strrep(x,pwd,'.'),filename_list,'UniformOutput',false);
        if isequal(filename_list,filename_list_old)
            warning('Cannot resolve relative path.');
        end
    end

end