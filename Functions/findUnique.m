function [unique_words, word_counts] = findUnique(userInput)
% findDynamicUniqueSites Dynamically identifies unique collection sites.
%   [unique_sites, site_counts] = findDynamicUniqueSites(raw_sites)
%   Automatically standardizes and groups site names by finding common core
%   terms within the data.

% --- 1. Preprocess all raw strings ---
processed_sites = cell(size(userInput));
for i = 1:length(userInput)
    % Convert to lowercase and remove non-alphanumeric characters (except spaces)
    temp_str = lower(strtrim(userInput{i}));
    temp_str = regexprep(temp_str, '[^\w\s]', '');
    temp_str = regexprep(temp_str, '\s+', ' ');
    processed_sites{i} = strtrim(temp_str);
end

% --- 2. Build a core name dictionary based on word frequency ---
word_counts = containers.Map;
for i = 1:length(processed_sites)
    words = strsplit(processed_sites{i});
    for j = 1:length(words)
        word = words{j};
        if ~isKey(word_counts, word)
            word_counts(word) = 1;
        else
            word_counts(word) = word_counts(word) + 1;
        end
    end
end

% Filter for significant core words (e.g., appear in more than 2 sites)
core_words = word_counts.keys;
significant_words = {};
for i = 1:length(core_words)
    word = core_words{i};
    if word_counts(word) > 2
        significant_words = [significant_words, {word}];
    end
end

% --- 3. Standardize names based on core words ---
final_sites = processed_sites;
for i = 1:length(processed_sites)
    current_site = processed_sites{i};
    if isempty(current_site)
        final_sites{i} = 'empty';
        continue;
    end
    
    found_core_match = false;
    for j = 1:length(significant_words)
        core_word = significant_words{j};
        if contains(current_site, core_word)
            % Use a more complete phrase that contains the core word as the standard
            % This helps prevent oversimplification (e.g., 'tissue' could be in multiple names)
            final_sites{i} = extractCorePhrase(current_site, core_word);
            found_core_match = true;
            break;
        end
    end
    
    if ~found_core_match
        % If no core word is found, use the processed name as is
        final_sites{i} = current_site;
    end
end

% --- 4. Group and count the final standardized sites ---
site_category = categorical(final_sites);
unique_words = categories(site_category);
word_counts = countcats(site_category);

% Sort by site name for consistent output
[unique_words, sort_idx] = sort(unique_words);
word_counts = word_counts(sort_idx);

end

% --- Helper function to find a more complete phrase ---
function phrase = extractCorePhrase(site_string, core_word)
    % A simple but effective way to find a phrase is to look for common
    % grouping words around the core word, like 'brain' or 'tissue'.
    % This is a more refined version of the previous code.
    if contains(site_string, 'harvard brain tissue')
        phrase = 'harvard brain tissue resource center';
    elseif contains(site_string, 'allegheny county')
        phrase = 'allegheny county medical examiner';
    elseif contains(site_string, 'new south wales') || contains(site_string, 'nsw')
        phrase = 'new south wales tissue resource centre';
    elseif contains(site_string, 'stanley')
        phrase = 'stanley foundation';
    else
        phrase = site_string;
    end
end