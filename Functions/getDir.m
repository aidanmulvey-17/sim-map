function folderLocation = getDir(addFolders)
% getDir gets the current script directory and optionally adds all
% subfolders to the MATLAB path.
folderLocation = pwd;
if nargin > 0 && islogical(addFolders) && addFolders == true
    % 'genpath(folderLocation)' generates a path string by recursively
    % including all subfolders from the specified folder.
    % 'addpath()' adds the specified path to the MATLAB search path.
    addpath(genpath(folderLocation));

    % Display a message to the user confirming the action.
    disp(['Added all subfolders in ' folderLocation ' to the path.']);
end
    
end