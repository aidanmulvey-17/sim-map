function selectedOptions = checkboxInputDialog(title, prompt, options)

% Initialize the selectedOptions array
selectedOptions = cell(1, length(options)-1);

% Create the dialog box with checkboxes
fig = figure('Name', title, 'Position', [100 100 300 200]);
uicontrol('Style', 'text', 'String', prompt, 'Position', [10 170 280 20]);

% Create checkboxes for each option
for i = 1:length(options)
    uicontrol('Style', 'radiobutton', 'String', options{i}, 'Position', [20 140-i*25 260 20], 'Callback', {@selection, i});
end

% Create OK and Cancel buttons
uicontrol('Style', 'pushbutton', 'String', 'OK', 'Position', [60 20 80 20], 'Callback', @okCallback);
uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [160 20 80 20], 'Callback', @closeFigure);

% Wait for user input
waitfor(fig);

% Function to handle checkbox selection
    function selection(hObject, eventdata, index)
        selectedOptions = hObject.String;
    end

% Function to handle OK button click
    function okCallback(hObject, eventdata)
        close(fig);
    end

% Function to handle Cancel button click
    function closeFigure(hObject, eventdata)
        selectedOptions = [];
        close(fig);
    end
end