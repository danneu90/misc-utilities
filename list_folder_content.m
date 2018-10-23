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

    if numel(varargin) > 0 && mod(numel(varargin),2)
        varargin = [{location} varargin];
        location = '.';
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
    
    assert(isfolder(location),'Input must be single folder.');

    dircontent = dir(location);
    ignore_file = cellfun(@(x) ismember(x(1),ignore_chars),{dircontent.name});
    if absolutepath
        filename_list = cellfun(@(x) [dircontent(1).folder,filesep,x],{dircontent(~[dircontent.isdir] & ~ignore_file).name},'UniformOutput',false);        
    else
        filename_list = cellfun(@(x) [location,filesep,x],{dircontent(~[dircontent.isdir] & ~ignore_file).name},'UniformOutput',false);
    end
end


