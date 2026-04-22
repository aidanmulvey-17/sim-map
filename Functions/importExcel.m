function varargout = importExcel(fileInput, varargin)
%importExcel imports your raw data based on the various sheet names. It
%will then clean any missing rows and return your varying number of tables

if ~endsWith(fileInput, '.xlsx')
    fileName = [fileInput '.xlsx'];
else
    fileName = fileInput;
end
if exist(fileName, 'file') ~= 2
    error('File not found.')
end

numOutputs = nargout;
if numOutputs ~= length(varargin)
    error('Number of output arguments must match number of sheet names')
end


for i = 1:numOutputs
    try
        sheetName = varargin{i};
        rawData = readtable(fileName, 'Sheet', sheetName, 'VariableNamingRule', 'preserve', 'EmptyRowRule', 'read');
        cleanData = rawData(any(~ismissing(rawData), 2), :);
        varargout{i} = cleanData;
    catch ME
        error('Error reading sheet %s: %s', sheetName, ME.message)
    end
end

end