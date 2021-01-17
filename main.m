
% let's load our image of the clock 
% that we will analyze
clockImageURL = 'analogni-sat-2.jpg';
clockImage = imread(clockImageURL);

% if testingMode is true we will display images 
% with each effect applied to see where it fails

testingMode = true;

% first we apply sobel edge detection and center
% detection with our sobelAndCenter function that we made
% and then we find all clock Hands on the image
% with getClockHands functtion that we made
[clockEdges,clockCenter,maxxy,minxy] = sobelAndCenter(clockImage,testingMode);

[clockHands,longerHand,clockCenter] = getClockHands(clockImage,clockEdges,clockCenter,maxxy,minxy,testingMode);


% If we could not find clock Hands, we use Default Center
% and we run our getClockHands function again with new center
% default center is height/2 and widht/2
if isempty(clockHands)
    info = imfinfo(clockImageURL);
    clockCenter(1) = info.Width/2;
    clockCenter(2) = info.Height/2;
    maxxy = [info.Width info.Height];
    minxy = [0 0];
    [clockHands,longerHand,clockCenter] = getClockHands(clockImage,clockEdges,clockCenter,maxxy,minxy,testingMode);
end
clockHandsFinal = struct('point1',{},'point2',{});

% if we found only one clock hand that means
% probably both hand are on the same place so 
% larger hand is hiding smaller one like 12:00
if length(clockHands) == 1
    newlongerHand = clockHands(1);
    clockHandsFinal(1) = clockHands(1);
    clockHandsFinal(2) = clockHands(1);
end
max_len = 0;
j=1;

% in the most general case where all three clock hands 
% are found minute hand second hand and hour hand

if length(clockHands) == 3
    for i = 1 : length(clockHands)
        if ~isequal(clockHands(i),longerHand)
            clockHandsFinal(j) = clockHands(i);
            len = norm(clockHandsFinal(j).point1 - clockHandsFinal(j).point2);
            if ( len > max_len)
              max_len = len;
              newlongerHand = clockHands(i);
            end
            j = j+1;
        end
    end
% for the case and clock where there is no 
% second hand only minute and hour
% we assign them to our clockHandsFinal and we point
% at the larger hand which is for minutes
       
elseif length(clockHands) == 2
    clockHandsFinal = clockHands;
    newlongerHand = longerHand;
end


% and the last step after we succesfully found
% all hands that we have on the image 
% we are based on the angle between them finding
% what time it is 

if isequal(clockHandsFinal(1),newlongerHand)
    minuteHand = clockHandsFinal(1).point2 - clockHandsFinal(1).point1;
    hourHand = clockHandsFinal(2).point2 - clockHandsFinal(2).point1;
else
    hourHand = clockHandsFinal(1).point2 - clockHandsFinal(1).point1;
    minuteHand = clockHandsFinal(2).point2 - clockHandsFinal(2).point1;
end



minuteHand = [minuteHand 0];
hourHand = [hourHand 0];
templateClock = [0 1 0];

% finding angles between minute and clock hand
% outside and inner angle

angle1 =  atan2d(norm(cross(minuteHand,templateClock)),dot(minuteHand,templateClock)) + 360*(norm(cross(minuteHand,templateClock))<0);
angle2 =  atan2d(norm(cross(hourHand,templateClock)),dot(hourHand,templateClock)) + 360*(norm(cross(hourHand,templateClock))<0);

% we reverse the found angles if it was 45
% between them it will use the 315 the outside
% angle from them

if minuteHand(1) > 0
    angle1 = 360 - angle1;
end

if hourHand(1) > 0
    angle2 = 360 -angle2;
end

% we assign our minute hand and hour hand
% with integer values that we exploated from
% angles between them in step above

minute = (angle1/6) + 60*(angle1/6 < 0);
hour = floor(angle2/30) + 12*(floor(angle2/30) <= 0);

% Displaying our result

disp(['Time on the clock is ',num2str(hour),':',num2str(minute)])