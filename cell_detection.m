%------------------------------------------------------------------------
% cell detection script
% 
% step 1: read image 
% step 2: detect cell outline 
% step 3: make outline more visible
% step 4: fill inner holes
% step 5: remove small objects 
% step 6: smoothen object
% step 7: draw outline
% 
% @input: greyscale image
% @return: greyscale image with 2 cells outlined
% 
%------------------------------------------------------------------------


%read image
I = imread('img\cell.tif');
figure, imshow(I), title('original image');

% edge-detection with binary gradient mask
% using sobel filter
fudgeFactor = .5;
[~, threshold] = edge(I, 'sobel');
I2 = edge(I,'sobel', threshold * fudgeFactor);
figure, imshow(I2), title('edge detection with sobel');

%dilate to give outline
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
I2 = imdilate(I2, [se90 se0]);
figure, imshow(I2), title('dilated gradient mask');

%fill interior gaps
I2 = imfill(I2, 'holes');
figure, imshow(I2), title('binary image with filled holes');

%remove small/noisy objects
I2 = bwareafilt(I2, 2);
figure, imshow(I2), title('noise removed');

%smoothen object
seD = strel('diamond',1);
I2 = imerode(I2,seD);
I2 = imerode(I2,seD);
figure, imshow(I2), title('segmented image');

%draw outline of segmented object
I2 = bwperim(I2);
Segout = I; 
Segout(I2) = 255; 
figure, imshow(Segout), title('outlined original image');