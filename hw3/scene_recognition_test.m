load('codebook.mat');
load('bag_of_words.mat');

num_of_clusters = 1000;
num_of_testing_examples = 2;
num_of_files_read = 0;

knn_labels = zeros(num_of_clusters, 1);

for i = 1:num_of_clusters
    knn_labels(i) = i;
end

bag_of_words = bag_of_words';

codebook_kdtree = vl_kdtreebuild(centers);
bag_of_words_kdtree = vl_kdtreebuild(bag_of_words);

testing_files = get_file_names('test');

current_class = 1;
num_of_matches = 0;
num_of_files = 0;

if ~isempty(testing_files)
    files = testing_files{1};
    files = strsplit(files, ' ');
    
    for index = 1:length(files)
        file = char(files(index));
        
        if ~isempty(file)
            img = imread(file);
            gray_img = single(rgb2gray(img));
            
            [f,d] = vl_sift(gray_img);
            
            bag_of_words_test = zeros(1, num_of_clusters);
            
            % Predict label from codebook and update bag of words
            for feature=d
                [predicted_label, ~] = vl_kdtreequery(codebook_kdtree, centers, double(feature), 'NumNeighbors', 20) ;
                bag_of_words_test(1, predicted_label) = bag_of_words_test(1, predicted_label) + 1;
            end
            
            % Predict corresponding scene (class)
            [label_index, ~] = vl_kdtreequery(bag_of_words_kdtree, bag_of_words, bag_of_words_test', 'NumNeighbors', 1) ;

            if bag_of_words_labels(label_index) == current_class
                num_of_matches = num_of_matches + 1;
            end
            
            num_of_files_read = num_of_files_read + 1;
            num_of_files = num_of_files + 1;
        end
        
        if num_of_files_read == num_of_testing_examples
            current_class = current_class + 1;
            num_of_files_read = 0;
        end
    end
end

display('Accuracy: ');
display(num_of_matches/num_of_files);
