function matchIndices = findAuthorMatches(authorList, referenceTable)
    % Input validation
    if isempty(authorList) || isempty(referenceTable)
        matchIndices = [];
        return;
    end
    
    % Ensure authorList is a cell array
    if ischar(authorList) || isstring(authorList)
        authorList = {authorList};
    end
    
    % Initialize output
    matchIndices = [];
    
    % Process each author
    for i = 1:length(authorList)
        if isempty(authorList{i})
            continue;
        end
        
        % Ensure string format and trim whitespace
        currentAuthor = strtrim(char(authorList{i}));
        
        % Find matches in reference table
        for j = 1:size(referenceTable, 1)
            refAuthor = strtrim(char(referenceTable{j, 1}));
            if strcmpi(currentAuthor, refAuthor)  % Case-insensitive comparison
                matchIndices = [matchIndices; j];
                break; % Found a match, move to next author
            end
        end
    end
end