training_files = get_file_names('train');

features = [];

dimensions_per_class = []; % order is fixed: trees people food faces cars buildings
dimensions = 0;

num_of_clusters = 1000;
num_of_classes = 6;
num_of_training_examples = 9;
num_of_files_read = 0;

if ~isempty(training_files)
    files = training_files{1};
    files = strsplit(files, ' ');
    
    for index = 1:length(files)
        file = char(files(index));
        
        if ~isempty(file)
            img = imread(file);
            gray_img = single(rgb2gray(img));
            
            [f,d] = vl_sift(gray_img);
            
            features = [features d];
            dimensions = dimensions + size(d, 2);
            
            num_of_files_read = num_of_files_read + 1;
        end
        
        % Reset counter
        if num_of_files_read == num_of_training_examples
            dimensions_per_class = horzcat(dimensions_per_class, dimensions); 
            dimensions = 0;
            num_of_files_read = 0;
        end
    end
end

[centers, labels] = vl_kmeans(double(features), num_of_clusters);

save('codebook.mat', 'labels' , 'centers');

kdtree = vl_kdtreebuild(centers);

current_class = 1;

bag_of_words = [];
bag_of_words_labels = [];

if ~isempty(training_files)
    files = training_files{1};
    files = strsplit(files, ' ');
    
    for index = 1:length(files)
        file = char(files(index));
        
        if ~isempty(file)
            img = imread(file);
            gray_img = single(rgb2gray(img));
            
            [f,d] = vl_sift(gray_img);
            
            b_o_g = zeros(1, num_of_clusters);
            
            % Predict label from codebook and update bag of words
            for feature=d
                [predicted_label, ~] = vl_kdtreequery(kdtree, centers, double(feature), 'NumNeighbors', 20) ;
                b_o_g(1, predicted_label) = b_o_g(1, predicted_label) + 1;
            end
            
            bag_of_words = [bag_of_words; b_o_g];
            bag_of_words_labels = [bag_of_words_labels; current_class];
            
            num_of_files_read = num_of_files_read + 1;
        end
        
        if num_of_files_read == num_of_training_examples
            current_class = current_class + 1;
            num_of_files_read = 0;
        end
    end
end

save('bag_of_words.mat', 'bag_of_words', 'bag_of_words_labels');
