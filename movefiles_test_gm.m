% Get the directory from the user using a GUI
sourceDirectory = uigetdir('', 'Select Source Directory');

% Check if the user canceled the operation
if sourceDirectory == 0
    disp('Operation canceled by user.');
    return; % Exit the script if the user canceled
end


sorted_files = sortFilesByHoldValue(sourceDirectory);
sorted_file_names = {sorted_files.name};

[~, baseName, ~] = fileparts(sorted_file_names{1});
baseName = baseName(1:end-1);
% Remove the last character
disp(['basename: ', baseName]);


for i=1:numel(sorted_files)
    %disp(sorted_file_names{i})
end


%RENAME PART
for i = 1:numel(sorted_files)
    originalFileName = sorted_files(i).name;
    %disp(['OG File Name: ', originalFileName]);

    newFileName = sprintf('%s%d.tif', baseName, i);
    %disp(['New File Name: ', newFileName]);
    

    % Rename the file if needed
    if ~strcmp(originalFileName, newFileName)
        movefile(fullfile(sourceDirectory, originalFileName), fullfile(sourceDirectory, newFileName));
    end
    
end


disp('Files renamed successfully!');

updatedFiles = sortFilesByHoldValue(sourceDirectory);
%{
for i=1:numel(updatedFiles)
    disp(updatedFiles(i).name)
end
%}

%BELOW IS ABOUT COPYING THE FILES INTO SAMPLED FOLDER
% Create a folder named "Sampled" inside the source directory

sampledFolder = fullfile(sourceDirectory, 'Sampled');
if exist(sampledFolder, 'dir') ~= 7
    mkdir(sampledFolder);
    disp('Sampled folder created successfully.');

    % Copy each file with .tif extension to the Sampled folder
    %with an increment of 5
    rounds_to_loop = floor(numel(updatedFiles)/5);

    for i = 1:5:numel(updatedFiles)
        sourceFile = fullfile(sourceDirectory, updatedFiles(i).name);
        destinationFile = fullfile(sampledFolder, updatedFiles(i).name);
        copyfile(sourceFile, destinationFile);
        %disp(['File ', updatedFiles(i).name, ' copied successfully.']);
    end
   disp('Operation Successfully Done')
else
    disp('Sampled folder already exists.');
end


function sorted_files = sortFilesByHoldValue(sourceDirectory)
    % Check if the specified directory exists
    if exist(sourceDirectory, 'dir') ~= 7
        error('Specified directory does not exist.');
    end

    % List all files in the source directory with .tif extension
    files = dir(fullfile(sourceDirectory, '*.tif'));

    % Extract file names
    fileNames = {files.name};

    % Function to calculate hold_value from filename
    function hold_value = calculateHoldValueFromFilename(filename)
        % Extract fileNumber
        fileNumber = regexp(filename, '\d+(?=\.[^.]*$)', 'match');
        fileNumber = round(str2double(fileNumber));

        % Extract cycleNumber
        cycleNumber = regexp(filename, '(?<=Ch\d_)\d+', 'match', 'once');
        cycleNumber = round(str2double(cycleNumber));

        % Calculate hold_value
        hold_value = cycleNumber * 100000 + fileNumber;
    end

    % Calculate hold_values for all files
    hold_values = cellfun(@calculateHoldValueFromFilename, fileNames);

    % Sort files based on their hold_value
    [~, sorted_indices] = sort(hold_values);
    sorted_files = files(sorted_indices);
end
