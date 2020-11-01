%INDIVIDUAL WORK 20028754 MADI ABZHANOV
%AUTOMATED DETECTION OF WORMS
clc; clear; close all; workspace; % clears Command Window and workspace and closes all open matlab figures 

%=======================================================================

% Prompt user to select image from computer and stores it in variable I
% If the user cancels selecting an image, the script is stopped

%         ======================== ======================== 	
[file,path] = uigetfile('*.png');
    if isequal(file,0)
% If the user presses the cancel button or exits the dialogue box 
       disp('User selected Cancel');
       return;
    else
% If user successfully selects an image which is then saved in I         
       disp(['User selected ', fullfile(path,file)]);
       RgbImage = imread(fullfile(path,file)); 
    end
%         ======================== ========================

fontsize = 15;

subplot(3,3,1); imshow(RgbImage);
title('Original image', 'FontSize', fontsize);

f = imadjust(uint8(RgbImage), stretchlim(RgbImage), []); %Adjust the image 

% Convert to grayscale
img_gray = rgb2gray(f);
subplot(3,3,2); imshow(img_gray);
title('Converted adjusted image to grayscale', 'FontSize', fontsize);
% Create morphological structuring element
se = strel('disk',20);

% White top-hat filtering.
th_fhiltered = imtophat(img_gray,se);

% Adjust image 
contrast_adjusted = imadjust(th_fhiltered);
subplot(3,3,3); imshow(contrast_adjusted);
title('Adjusted white top-hat filtered image', 'FontSize', fontsize);

%   2-D median filtering
K = medfilt2(img_gray);
%   Contrast-limited Adaptive Histogram Equalization
J = adapthisteq(K,'cliplimit',0.5);
%   Create predefined 2-D filters
H = fspecial('average', [9 3]);
%   N-D filtering of multidimensional images.
f_avg = imfilter(J,H,'replicate');
contrast_adj_image = contrast_adjusted-1.2*f_avg;
subplot(3,3,4); imshow(contrast_adj_image);
title('Contrast adjusted image', 'FontSize', fontsize);


%NOISE REDUCTION using Wiener function
NR = wiener2(contrast_adj_image,[700 700]);
subplot(3,3,5); imshow(NR);
title({'Image with Noise removed'; 'by Wiener Filter'}, 'FontSize', fontsize);    

%Thresholding using Otsu's method
level = graythresh(NR);
bw = im2bw(NR, level);
subplot(3,3,6); imshow(bw);
title({'Image converted to binary'; 'using thresholding Otsu method'}, 'FontSize', fontsize);

bw = imfill(bw, 'holes');   %Fill the holes after converting to binary
subplot(3,3,7); imshow(bw);
title('Image after filling the holes', 'FontSize', fontsize);

finalim = imclose(bw, strel('disk', 4)); %Close the unconnected pixels 
finalim = bwareaopen(finalim,5000); %Remove any unecessary pixels or structures around the worm
finalim = imfill(finalim, 'holes'); %Fill the remaining holes
finalim = imclose(finalim, strel('disk', 7)); %Final closure of unconnected pixels
subplot(3,3,8); imshow(finalim);
title({'Closed image with unecessary pixels'; 'removed and filled the remaining holes'},'FontSize', fontsize);

%Make the edges more smooth 
width = 15;
kernel = ones(width) / width^2;
blurryImage = conv2(double(finalim), kernel, 'same');
finalim = blurryImage > 0.5;
finalim = bwareaopen(finalim, 500);

%Count the total surface area of worm's body by counting total number of
%white pixels
nWhite = sum(finalim(:));
A = nWhite;
caption = sprintf('The total surface area = %d',A);
subplot(3,3,9); imshow(finalim);
title({'Final mask.'; caption}, 'FontSize', fontsize);

% 2. Get the boundary.
% First, display the original image.
figure;
imshow(RgbImage, []);
axis image;
hold on;
%GET THE BOUNDARY
boundaries = bwboundaries(finalim);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off;
caption = sprintf('Boundary of the worm. %d Outlines, from bwboundaries()', numberOfBoundaries);
title(caption, 'FontSize', fontsize); 
axis on;












