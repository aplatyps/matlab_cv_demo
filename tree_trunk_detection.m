%------------------------------------------------------------------------
% Tree Trunk Detection
% 
% step 1 : read image
% step 2 : increase tone contrast with gamma correction
% step 3 : create binary image from the average of column pixels
% step 4 : sharpen image
% step 5 : filter image with local range to separate foreground and
%         background
% step 6 : convert to image to greyscale
% step 7 : convert to image to binary
% step 8 : union of binary images from step 3 and step 7
% step 9 : remove noise and unwanted parts by wiener filter, eroding and 
%          remove based on surface area
% step 10: check if the segments match texture of tree trunk
% step 11: label match and display the labeled image
% 
% @input: coloured image
% @return: labeled colour image
% 
%------------------------------------------------------------------------

% main function
function tree_detection(I,J)

    %read image
    %figure, imshowpair(I, J, 'montage'), title('original image');
    
    % gamma correction
    I2 = imadjust(I,[],[],1.5);
    figure, imshow(I2), title('increased gamma');

    % create a binary image that exploits the long trunk shape
    MI = averaging(I2);
    
    % sharpening
    I2 = imsharpen(I,'Amount', 0.5, 'Threshold', 0.7);
    figure, imshow(I2), title('sharpen');
    
    % local range of image
    I2 = rangefilt(I2, true(9));
    figure, imshow(I2), title('result of range filtering');
    
    % rgb to greyscale
    I2 = rgb2gray(I2);
    figure, imshow(I2), title('greyscale image');

    % thresholding to binary with adaptive threshold
    % calculates the local intensity and convert to binary image
    level = adaptthresh(I2, 0.6, 'ForegroundPolarity','dark','Statistic','gaussian');
    IB2 = imbinarize(I2,level);
    figure, imshow(I2), title('binary image with adaptive threshold');

    % compare both binary images, only take pixels 
    % that exist in both images
    I2 = and(~MI, ~IB2);
    figure, imshow(MI), title('binary image by averaging');
    figure, imshow(I2), title('define tree segments by union');   
        
    % remove small/noisy objects
    I2 = wiener2(I2,[3 3]);
    % separate parts
    I2 = imerode(I2, true(7));
    % improve tree structure
    I2 = imfill(I2,'holes');
    % remove estimated unwanted area
    pI = round(sum(I2(:))*0.08);
    I2 = bwareaopen(I2,pI,8);
    figure, imshow(I2), title('noise removed'); 
    

    % label image only if the remaining segment 
    % matches the texture of a tree trunk
    labeledImage = bwlabel(I2);
    % get segments areas and positions
    measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
    figure, imshow(I), title('extracted');
    
    % take each segment area for labeling
    for k = 1 : length(measurements)
      thisBB = measurements(k).BoundingBox;
      rect = [thisBB(1),thisBB(2),thisBB(3),thisBB(4)];
      seg = imcrop(I,rect);
      % label only if match tree texture
      f = texture_matching(seg);
      if f == 1
          rectangle('Position', rect,'EdgeColor','r','LineWidth',2 )
      end
    end
end

% perform column averaging
function I = averaging(I)
    I = rgb2gray(I);
    
    % take the mean value of each column
    M = mean(I);
    M2 = [];
    M3 = [];
    for a = 1:size(M,2)
        M2 = [M2 round(M(a))];
    end
    % replace each value with column mean
    for a = 1:size(I,1)
        M3 = [M3; M2];
    end
    M = mat2gray(M3);

    % convert to binary with 
    % gaussian weighted mean in neighbourhood
    level = adaptthresh(M, 0.75,'Statistic','gaussian');
    M = imbinarize(M,level);
    M = ~M;
    CC = bwconncomp(M);
    p = round((sum(M(:))/CC.NumObjects)*0.98);
    M = bwareaopen(M, p);
    
    % removes tiny sections that are likely
    % unwanted parts
    M = ~M;
    CC = bwconncomp(M);
    p = round((sum(M(:))/CC.NumObjects)*0.025);
    I = bwareaopen(M, p);
end

% compare features of a pre-defined image
function flag = texture_matching(seg)  
     % read texture
     T = imread('texture.jpg');
     
     % adjust gamma
     seg = imadjust(seg,[],[],1.5);
     
     % convert both to greyscale
     T = rgb2gray(T);
     seg = rgb2gray(seg);
     
     % resize texture according to segment
     [r,c] = size(seg);
     T=imresize(T, [r, c]);
     
     % extract features
     lbpT = extractLBPFeatures(T);
     lbpseg = extractLBPFeatures(seg);
     
     % compare features with squared error
     sqrterr = (lbpseg - lbpT).^2;
     
     % fail matching if error is too high
     if sum(sqrterr, 'native') < 0.9
         flag = 1;
     else
         flag = 0;
     end
end