function [ file_names ] = get_file_names( option )
% Get all file names (for either training or testing)

file_names = '';

file_number_regex = '[0-9]+';

directories = 'images/trees images/people images/food images/faces images/cars images/buildings';

directories = strsplit(directories, ' ');

for index = 1:length(directories)
    directory = char(directories(index));
    
    dirlist = dir(directory);
    
    for i = 1:length(dirlist)
        file_number = regexp(dirlist(i).name, file_number_regex, 'match');
        
        [x, y] = size(file_number);
        
        if (x > 0 && y > 0)
            number = str2double(file_number{1});
            
            if strcmp(option, 'train')
                if (1 <= number && number <= 9)
                    full_path = strcat(directory, {'/'}, dirlist(i).name);
                    file_names = strcat(file_names, {' '}, full_path);
                end
            end
            
            if strcmp(option, 'test')
                if (9 < number)
                    full_path = strcat(directory, {'/'}, dirlist(i).name);
                    file_names = strcat(file_names, {' '}, full_path);
                end
            end
        end
    end
end

end

