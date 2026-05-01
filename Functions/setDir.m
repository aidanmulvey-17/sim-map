function currentFileDirectory = setDir(varargin)
% Gets the directory of the current file and optionally manages the MATLAB path.
%
%   currentFileDirectory = setDir()
%   currentFileDirectory = setDir('GoPath', true)
%   currentFileDirectory = setDir('SavePath', true)
%   currentFileDirectory = setDir('GoPath', true, 'SavePath', false)
%   currentFileDirectory = setDir('Folders', {'all', 'data', 'scripts/utils'}) % Add specific subfolders
%
%   Inputs (Name-Value Pairs):
%     'GoPath'   - (Optional) Logical (true/false) or string ('on'/'off', 'add'/'noadd').
%                   If true, 'on', or 'add', all subfolders of the current file's
%                   directory are added to the MATLAB path for the current session
%                   (unless 'Folders' is specified). Default is false.
%     'Folders'  - (Optional) Cell array of strings or a single string.
%                   Specifies names of subfolders (relative to the current file's
%                   directory) to add to the MATLAB path. If provided, 'GoPath'
%                   will add only these specific folders instead of using genpath.
%                   Example: {'data', 'src/algorithms'}
%     'SavePath'  - (Optional) Logical (true/false) or string ('on'/'off').
%                   If true or 'on', the modified path is saved for future
%                   MATLAB sessions. Use with caution, as it permanently
%                   modifies your MATLAB pathdef.m file. Default is false.
%
%   Output:
%     currentFileDirectory - The full path to the directory containing the
%                            currently executing file.
%
%   Examples:
%     % Get the directory and change to it, without adding to path
%     myDir = setDir();
%
%     % Get the directory, change to it, and add ALL its subfolders to the path
%     myDir = setDir('GoPath', true);
%
%     % Get the directory, change to it, and add ONLY 'data' and 'src' subfolders
%     myDir = setDir('GoPath', true, 'Folders', {'data', 'src'});
%     % Or simply:
%     myDir = setDir('Folders', {'data', 'src'}); % 'GoPath' is implicitly true if 'Folders' is used
%
%     % Add a single specific subfolder
%     myDir = setDir('Folders', 'my_functions');
%
%     % Add to path and save for future sessions (using specific folders)
%     myDir = setDir('Folders', {'lib', 'tests'}, 'SavePath', 'on');

p = inputParser;

defaultGoPath = false;
defaultSavePath = false;
defaultFolders = {};

addParameter(p, 'GoPath', defaultGoPath, @(x) islogical(x) || (ischar(x) && (strcmpi(x,'on') || strcmpi(x,'off') || strcmpi(x,'add') || strcmpi(x,'noadd'))));
addParameter(p, 'Folders', defaultFolders, @(x) iscellstr(x) || ischar(x));
addParameter(p, 'SavePath', defaultSavePath, @(x) islogical(x) || (ischar(x) && (strcmpi(x,'on') || strcmpi(x,'off'))));

parse(p, varargin{:});

goPathOption = p.Results.GoPath;
savePathOption = p.Results.SavePath;
foldersOption = p.Results.Folders;

if ischar(goPathOption)
    goPathFlag = strcmpi(goPathOption, 'on') || strcmpi(goPathOption, 'add');
else
    goPathFlag = goPathOption;
end

if ischar(savePathOption)
    savePathFlag = strcmpi(savePathOption, 'on');
else
    savePathFlag = savePathOption;
end

if ischar(foldersOption)
    foldersOption = {foldersOption};
end

if ~isempty(foldersOption)
    goPathFlag = true;
end

currentFileDirectory = '';

try
    fullPath = matlab.desktop.editor.getActiveFilename;
    if ~isempty(fullPath)
        currentFileDirectory = fileparts(fullPath);
        disp('setDir: Detected as Live Script via active editor.');
    end
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        warning('setDir: ActiveEditorFailed', ...
            'Could not get active editor filename. Error: %s. Attempting fallback.', ME.message);
    end
end

if isempty(currentFileDirectory)
    fullPath = mfilename('fullpath');
    if ~isempty(fullPath)
        currentFileDirectory = fileparts(fullPath);
        disp('setDir: Detected as .m file or Live Script run directly.');
    else
        currentFileDirectory = pwd;
        warning('setDir:CalledFromCommandWindow', ...
            'Could not determine file path. Returning current working directory (pwd).');
    end
end

if ~isempty(currentFileDirectory)
    cd(currentFileDirectory);
    disp(['setDir: Changed current working directory to: ', currentFileDirectory]);

    if goPathFlag
        if isempty(foldersOption) || strcmpi(foldersOption{1}, 'all')
            addpath(genpath(currentFileDirectory));
            disp('setDir: All subfolders of the current file directory have been added to the path for this session.');
        else
            addedFolders = {};
            for i = 1:numel(foldersOption)
                subfolderPath = fullfile(currentFileDirectory, foldersOption{i});
                if exist(subfolderPath, 'dir') == 7
                    addpath(subfolderPath);
                    addedFolders{end+1} = foldersOption{i};
                else
                    warning('setDir:FolderNotFound', 'Subfolder ''%s'' not found in %s. Skipping.', foldersOption{i}, currentFileDirectory);
                end
            end
            if ~isempty(addedFolders)
                disp(['setDir: The following specific subfolders have been added to the path: ', strjoin(addedFolders, ', ')]);
            else
                disp('setDir: No specific subfolders were found or added based on the "Folders" option.');
            end
        end
    else
        disp('setDir: Skipping adding to path based on "GoPath" option.');
    end

    if savePathFlag
        try
            savepath; % This saves the current path to pathdef.m
            disp('setDir: Path saved for future MATLAB sessions.');
        catch ME
            warning('setDir:SavePathFailed', ...
                'Could not save path. You might not have write permissions to pathdef.m. Error: %s', ME.message);
        end
    else
        disp('setDir: Skipping saving path based on "SavePath" option.');
    end
else
    warning('setDir: NoDirectoryFound', ...
        'Could not determine a valid directory for path operations.');
end

end
