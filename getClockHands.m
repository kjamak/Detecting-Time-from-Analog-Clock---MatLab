function [clockHands,longerHand,newClockCenter] = getClockHands(clockImage,clockEdges,center,maxxy,minxy,testingMode)
    %convert image to gray
    clockImage = rgb2gray(clockImage);
    clockImage = imadjust(clockImage);
    
    %get hough lines
    [H, theta, rho] = hough(clockEdges);
    peaks = houghpeaks(H,70,'threshold',ceil(0.01*max(H(:))));
    lines = houghlines(clockEdges, theta, rho, peaks,'FillGap',15,'MinLength',40);
    
    %show for testing
    if testingMode
        figure;
        subplot(1,3,1);
        imshow(clockImage), hold on
        title('hough lines with center detected');
        scatter(center(1),center(2));
    end
    
    min_len = 0.1*min(maxxy - minxy);
    max_len = 0;
    newlines = struct('point1',{},'point2',{});
    i=1;
    newClockCenter = zeros(1,2);
    %get closer center
    for k = 1:length(lines)
        D1 = [lines(k).point1;center];
        D2 = [lines(k).point2;center];
        if xor(pdist(D1) <= min_len , pdist(D2) <= min_len)
            i = i+1;
            if(pdist(D1) <= min_len)
                newClockCenter = newClockCenter + lines(k).point1;
            else
                newClockCenter = newClockCenter + lines(k).point2;
            end
        end
        xy = [lines(k).point1; lines(k).point2];
        len = norm(lines(k).point1 - lines(k).point2);
        if ( len > max_len)
          max_len = len;
          longerHandxy = xy;
          longerHand = lines(k);
        end
        if testingMode
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        end
    end
    
    %show for testing
    if testingMode
        %longerHand line
        plot(longerHandxy(:,1),longerHandxy(:,2),'LineWidth',2,'Color','red');
    end
    
    %new center
    newClockCenter = newClockCenter/(i-1);
    min_len = min_len/2;
    max_len = 0;
    i=1;
    
    %show for testing
    if testingMode
        subplot(1,3,2);
        imshow(clockImage), hold on
        title('Hough Lines with more precise center');
        scatter(newClockCenter(1),newClockCenter(2));
    end
    
    %lines close to the new center
    for k = 1:length(lines)
        D1 = [lines(k).point1;newClockCenter];
        D2 = [lines(k).point2;newClockCenter];
        if xor(pdist(D1) <= min_len , pdist(D2) <= min_len)
            newlines(i).point1 = lines(k).point1;
            newlines(i).point2 = lines(k).point2;
            if(pdist(D1) <= min_len)
                newlines(i).point1 = newlines(i).point2
                newlines(i).point2 = newClockCenter;
            else
                newlines(i).point2 = newClockCenter;
            end
            xy = [newlines(i).point1; newlines(i).point2];
            len = norm(newlines(i).point1 - newlines(i).point2);
            if ( len > max_len)
              max_len = len;
              longerHandxy = xy;
              longerHand = newlines(i);
            end
            if testingMode
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            end
            i=i+1;
        end
    end
    
    %show for testing
    if testingMode
        %longerHand line
        plot(longerHandxy(:,1),longerHandxy(:,2),'LineWidth',2,'Color','red');
    end
    
    %get the final lines and combine close ones based on angel
    clockHands = struct('point1',{},'point2',{});
    
    %show for testing
    if testingMode
        subplot(1,3,3);
        imshow(clockImage), hold on
        title('final arrows with merging detected');
        scatter(newClockCenter(1),newClockCenter(2));
    end
    
    max_len = 0;
    i=1;
    for k = 1:length(newlines)
        maxline = newlines(k);
        for j = 1:length(newlines)
            v1 = newlines(k).point2 - newlines(k).point1;
            v2 = newlines(j).point2 - newlines(j).point1;
            v1 = [v1 0];
            v2 = [v2 0];
            angle = atan2d(norm(cross(v1,v2)),dot(v1,v2)) + 360*(norm(cross(v1,v2))<0);
            check = true;
            for x=1:length(clockHands)
                if isequal(newlines(k),clockHands(x)) || isequal(newlines(j),clockHands(x))
                    check = false;
                end
            end
            if angle <= 15 && k ~= j
                if ~check
                    break
                end
                D1 = [maxline.point1;maxline.point2];
                D2 = [newlines(j).point1;newlines(j).point2];
                if pdist(D1) < pdist(D2)
                    maxline = newlines(j);
                end
            end
        end
        if check
            clockHands(i) = maxline;
            
            xy = [clockHands(i).point1; clockHands(i).point2];
            len = norm(clockHands(i).point1 - clockHands(i).point2);
            if ( len > max_len)
                max_len = len;
                longerHandxy = xy;
                longerHand = clockHands(i);
            end
            %show for testing
            if testingMode
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            end
            i = i+1; 
        end
    end
    if testingMode
        %longerHand line
        plot(longerHandxy(:,1),longerHandxy(:,2),'LineWidth',2,'Color','red');
    end


end