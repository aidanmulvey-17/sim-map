function figHandle = pub_format(figHandle, baseName, journal, widthType, doExport)
    % 1. Input Handling
    if nargin < 5, doExport = false; end
    if isempty(figHandle) || ~isgraphics(figHandle, 'figure'), figHandle = gcf; end

    %% 2. The Journal Database
    switch lower(journal)
        case 'nature'
            fName = 'Arial'; fSize = 7; lSize = 8; widths = [8.9, 12.0, 18.3]; 
        case {'cell', 'neuron'}
            fName = 'Helvetica'; fSize = 6; lSize = 9; widths = [8.5, 11.4, 17.4];
        case 'pnas'
            fName = 'Arial'; fSize = 8; lSize = 10; widths = [8.9, 11.4, 17.8];
        case 'science'
            fName = 'Arial'; fSize = 8; lSize = 9; widths = [8.0, 12.0, 17.6];
        case {'jneurosci', 'jneuro'}
            fName = 'Arial'; fSize = 8; lSize = 10; widths = [8.5, 11.6, 17.6];
        case 'apa'
            fName = 'Arial'; fSize = 9; lSize = 10; widths = [8.9, 13.0, 18.0];
        otherwise
            fName = 'Arial'; fSize = 8; lSize = 10; widths = [8.9, 11.4, 17.8];
    end

    switch lower(widthType)
        case {'single', '1'}, colWidth = widths(1);
        case '1.5', colWidth = widths(2);
        case {'double', '2'}, colWidth = widths(3);
        otherwise, colWidth = widths(1);
    end

    %% 3. Figure Canvas Setup
    set(figHandle, 'Units', 'centimeters', 'Color', 'w');
    pos = get(figHandle, 'Position');
    set(figHandle, 'Position', [pos(1), pos(2), colWidth, pos(4)]);

    %% 4. Process Axes & Data Styling
    black = [0 0 0]; 
    if any(strcmpi(journal, {'nature', 'cell'}))
        dataLineWidth = 0.6; markerSize = 55;
    else
        dataLineWidth = 0.75; markerSize = 60;
    end
    
    allAx = findall(figHandle, 'type', 'axes');
    allAx = flipud(allAx); 
    alphabet = 'abcdefghijklmnopqrstuvwxyz';

    for i = 1:length(allAx)
        ax = allAx(i);
        
        % A. Structural Black & Axis Properties
        set(ax, 'FontName', fName, 'FontSize', fSize, 'LineWidth', 0.5, ...
                'TickDir', 'out', 'Box', 'off', ...
                'XColor', black, 'YColor', black, 'ZColor', black);
        
        % B. Lines: Protect Significance Markers
        hLines = [findall(ax, 'Type', 'Line'); findall(ax, 'Type', 'ConstantLine')];
        for k = 1:length(hLines)
            % Skip formatting if the line is actually an asterisk marker
            if isprop(hLines(k), 'Marker') && ~isempty(hLines(k).Marker) && ~strcmp(hLines(k).Marker, 'none')
                continue; 
            end
            set(hLines(k), 'Color', black);
            if isprop(hLines(k), 'Alpha'), hLines(k).Alpha = 1.0; end
            if hLines(k).LineWidth > 0.1, hLines(k).LineWidth = dataLineWidth; end
        end

        % C. Scatter/Data Points
        hScatters = findall(ax, 'Type', 'Scatter');
        for s = 1:length(hScatters)
            hScatters(s).SizeData = markerSize;
        end
        
        % D. Text: Significance & Legend Protection
        allText = findall(ax, 'Type', 'text');
        for t = 1:length(allText)
            txt = allText(t);
            % 1. Detect significance asterisks (containing '*')
            if contains(txt.String, '*')
                set(txt, 'FontName', 'Arial', 'FontSize', fSize+2, 'FontWeight', 'bold');
                continue; % Don't move these
            end
            
            % 2. Move interpretation labels if necessary
            if isequal(txt.Units, 'normalized') && txt.Position(2) < 0
                txt.VerticalAlignment = 'top'; 
                txt.Position(2) = -0.15; % Deeper clearance
            end
            set(txt, 'FontName', fName, 'FontSize', fSize-0.5);
        end

        % E. Global Figure Title (Centered to Canvas)
        if ~isempty(ax.Title.String)
            tStr = ax.Title.String;
            ax.Title.String = ''; 
            annotation('textbox', [0, 0.9, 1, 0.1], 'String', tStr, ...
                'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                'FontSize', fSize+1, 'FontWeight', 'bold', 'FontName', fName);
        end

        % F. Panel Labeling
        if length(allAx) > 1
            text(ax, -0.05, 1.05, alphabet(i), 'Units', 'normalized', ...
                 'FontSize', lSize, 'FontWeight', 'bold', 'FontName', fName, ...
                 'Color', black, 'Clipping', 'off');
        end
    end

    %% 5. Polish Legends (Fix Font and Symbols)
    allLegs = findall(figHandle, 'Type', 'legend');
    for l = 1:length(allLegs)
        set(allLegs(l), 'FontName', fName, 'FontSize', fSize-1, ...
            'EdgeColor', 'none', 'Location', 'best');
        % Prevents symbols from becoming massive
        allLegs(l).ItemTokenSize = [12, 6]; 
    end

    %% 6. Final Export
    if doExport
        suffix = sprintf('_%s_%s', journal, widthType);
        finalName = [baseName, suffix];
        exportgraphics(figHandle, [finalName, '.pdf'], 'ContentType', 'vector', 'BackgroundColor', 'none');
        exportgraphics(figHandle, [finalName, '.tif'], 'Resolution', 600);
        fprintf('Success: Exported %s\n', finalName);
    end
end