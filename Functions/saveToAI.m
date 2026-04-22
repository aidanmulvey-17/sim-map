function saveToAI(folderLocation,nameFile)
%saveToAI saves a MATLAB figure as an eps to be easily worked with in adobe
%illustrator, given the folder location and file name
folderPath = folderLocation;
fileName = append(nameFile, '.eps');
fileName = fullfile(folderPath, fileName);
exportgraphics(gcf,fileName,'BackgroundColor','none','ContentType','vector')
end