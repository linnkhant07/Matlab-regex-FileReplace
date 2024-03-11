% Specify the directory from the user using a GUI
sourceDirectory = uigetdir('', 'Select Source Directory');

% Check if the user canceled the operation
if sourceDirectory == 0
    disp('Operation canceled by user.');
    return; % Exit the script if the user canceled
end

sorted_files = sortFilesByHoldValue(sourceDirectory);
sorted_file_names = {sorted_files.name};

% Extract base name from the first sorted file
[~, baseName, ~] = fileparts(sorted_file_names{1});
baseName = regexprep(baseName, '_\d+\.tif_\d+$', ''); % Remove _number.tif_number
baseName = baseName(1:end-16);

% Display base name
disp(['Base Name: ', baseName]);

for i=1:numel(sorted_files)
    %disp(sorted_file_names{i})
end


%RENAME PART
for i = 1:numel(sorted_files)
    originalFileName = sorted_files(i).name;
    %disp(['OG File Name: ', originalFileName]);

    % Pad the index with leading zeros
    newIndex = sprintf('%06d', i);
    omeExt = '.ome';

    newFileName = sprintf('%s%s%s.tif', baseName, newIndex, omeExt);
    %disp(['New File Name: ', newFileName]);
    

    % Rename the file if needed
    if ~strcmp(originalFileName, newFileName)
        movefile(fullfile(sourceDirectory, originalFileName), fullfile(sourceDirectory, newFileName));
    end
    
end

disp('Files renamed successfully!');


%BELOW IS ABOUT COPYING THE FILES INTO SAMPLED FOLDER
% Create a folder named "Sampled" inside the source directory

% checking - List all files in the source directory with .tif extension
files = dir(fullfile(sourceDirectory, '*.tif'));

% Extract file names
%fileNames = {files.name};

for i=1:numel(files)
    %disp(fileNames{i})
end



sampledFolder = fullfile(sourceDirectory, 'Sampled');
if exist(sampledFolder, 'dir') ~= 7
    mkdir(sampledFolder);
    disp('Sampled folder created successfully.');

    %for naming from 1 again
     j = 1;

    % Copy each file with .tif extension to the Sampled folder
    %with an increment of 5
    rounds_to_loop = floor(numel(files)/5);

    for i = 1:5:numel(files)
        
        % Pad the index with leading zeros
        newIndex = sprintf('%06d', j);
        omeExt = '.ome';
    
        newFileName = sprintf('%s%s%s.tif', baseName, newIndex, omeExt);
        %disp(['New File Name: ', newFileName]);

    
        sourceFile = fullfile(sourceDirectory, files(i).name);
        destinationFile = fullfile(sampledFolder, newFileName);
        copyfile(sourceFile, destinationFile);
        disp(['File ', files(i).name, ' copied successfully.']);
        j = j + 1;
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
