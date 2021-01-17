function [clockEdges,clockCenter,maxxy,minxy] = sobelAndCenter(clockImage,testingMode)
    
    % First step is to convert our Image to black and white

    clockImage = rgb2gray(clockImage);
    clockImage = imadjust(clockImage);
    

    % Then we find clock edges using Sobel

    clockSobel=medfilt2(clockImage,[5 5]);
    clockEdges = edge(clockSobel,'sobel');
    
   
    % Then we apply the strel to our image with edges found with sobel

    clockStrel = strel('square', 5);
    EnhancedclockEdges = imdilate(clockEdges, clockStrel);    
    EdgeClean = bwareaopen(EnhancedclockEdges,1e3);

    
    %Then we go on finding the center of the clock 
    % first by finding boundaries

    [B,L,N] = bwboundaries(EdgeClean,8,'noholes');
    

    [maxcellsize,maxcellind] = max(cellfun(@numel,B));
    maxxy = max(B{maxcellind},[],1);
    minxy = min(B{maxcellind},[],1);
    
    %clockCenter (y,x)
    clockCenter = (maxxy + minxy) / 2;
    temp = clockCenter(2);
    clockCenter(2) = clockCenter(1);
    clockCenter(1) = temp;

    
    % If the testingMode is on we show our images with applied effects
    % so we can explore the error if there is any

    if testingMode

        figure;
        subplot(2,3,1);
        imshow(clockImage);
        title('B&W Image');

        subplot(2,3,2);
        imshow(clockEdges);
        title('Clock Edges');
       
        subplot(2,3,3);
        imshow(EdgeClean);
        title('strel(clockEdges)');

        subplot(2,3,4);
        imshow(clockImage); hold on;
        title('Image boundaries');
        for k=1:length(B),
           boundary = B{k};
           if(k > N)
             plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
           elclockStrel
             plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
           end
        end


        subplot(2,3,5);
        imshow(clockImage); hold on;
        scatter(clockCenter(1),clockCenter(2));
        title('detected clockCenter');




    end






    
end


    