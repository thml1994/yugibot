function [ ] = yugibot(time)

tau = 0.3;
%tau = 0.1;
import java.io.*;
import java.awt.*;
robot = Robot;

pause(time);
p0 = get(0,'PointerLocation');
flag = true;

data = struct;
data.F = zeros(40,40);
data.name = cell(40,1);
data.robot = robot;
data.count = 1;

while(flag)
    disp('Waiting for turn');
    while(~checkTurn(robot))
        if(checkEOB(robot))
            robot.pressButton('z',1);
            pause(40*tau);
            robot.pressButton('z',1);
            pause(40*tau);
            robot.pressButton('x',1);
            pause(40*tau);
        end
        pause(tau);
    end
    pause(5*tau);
    data = battleIteration(robot, data, tau);
    disp('End of battle iteration');
    pause(10*tau);
    
    if(any(get(0,'PointerLocation') ~= p0))
        flag = false;
    end
    
    
end
end

function [screen] = screenshot(robot)
import java.awt.*;
Toolkit.getDefaultToolkit();
img = robot.createScreenCapture(Rectangle(404,205,639,479));
pic = java_img2mat(img);
screen = rgb2gray(pic);
end

function [data] = battleIteration(robot, data, tau)

disp('scanning hand');
hand = scanHand(robot);

cardid = zeros(5,1);
for i=1:5
    k = find(strcmp(data.name, hand.name{i}),1);
    if(isempty(k))
        data.name{data.count} = hand.name{i};
        data.count = data.count + 1;
    else
        cardid(i) = k;
    end
end

%[card1, card2] = find(data.F(cardid,cardid) ~= 0);

[~,ind] = max(hand.atk);
disp('summoning');
robot.pressButton('left',5-ind);
if(ind==5)
    ind2 = 4;
    robot.pressButton('left',1);
    robot.pressButton('up',1);
    robot.pressButton('right',1);
    robot.pressButton('up',1);

else
    ind2 = ind + 1;
    robot.pressButton('right',1);
    robot.pressButton('up',1);
    robot.pressButton('left',1);
    robot.pressButton('up',1);
end
robot.pressButton('z',2,5);
robot.pressButton('z',1,10);
robot.pressButton('z',1,5);

pause(3*tau);
cardData = scanPlayerData(robot);
if(cardData.atk > hand.atk(ind))
    data.F(ind,ind2) = cardData.atk;
    data.F(ind2,ind) = cardData.atk;
    disp(cardData.atk)
end

robot.pressButton('left',4);
disp('attacking');
robot.attackIteration(tau);
robot.pressButton('v',1);
robot.pressButton('x',1);
end

function [hand] = scanHand(robot)
%robot.pressButton('left',4);
hand = struct;
hand.atk = zeros(5,1);
hand.name = cell(5,1);
for i=1:5
    playerData = scanPlayerData(robot);
    hand.atk(i) = playerData.atk;
%    hand.def(i) = playerData.def;
    hand.name{i} = playerData.name;
    robot.pressButton('right',1);
end
end

function [data] = scanPlayerData(robot)
screen = screenshot(robot);

data = struct;
name = screen(425:448,30:420);
atk = screen(423:436,444:502);
%def = screen(439:452,444:502);
%attr1 = screen(420:455,548:575);
%attr2 = screen(420:455,580:613);

OCR = ocr(atk, 'CharacterSet', '0123456789', 'TextLayout', 'Line');
if(~isempty(OCR.Words))
    data.atk = str2double(OCR.Words{1});
else
    data.atk = -1;
end
% OCR = ocr(def, 'CharacterSet', '0123456789', 'TextLayout', 'Line');
% if(~isempty(OCR.Words))
%     data.def = str2double(OCR.Words{1});
% else
%     data.def = -1;
% end

OCR = ocr(name, 'TextLayout', 'Line');
if(~isempty(OCR.Words))
    data.name = strcat(OCR.Words{:});
else
    data.name = '';
end

end

function [data] = scanOpponentData(robot)
pause(1)
screen = screenshot(robot);

data = struct;
%nameR = screen((425:448) - 175,30:420);
atkR = screen((423:436) - 175,442:502);
defR = screen((439:452) - 175,442:502);
starR = screen((420:455) - 175,548:613);

OCR = ocr(atkR, 'CharacterSet', '0123456789', 'TextLayout', 'Line');
if(~isempty(OCR.Words))
    data.atk = str2double(OCR.Words{1});
else
    data.atk = -1;
end

OCR = ocr(defR, 'CharacterSet', '0123456789', 'TextLayout', 'Line');
if(~isempty(OCR.Words))
    data.def = str2double(OCR.Words{1});
else
    data.def = -1;
end

data.star = sum(starR(starR > 10));
end

function [] = pressButton(robot, button, n, delay)
if(nargin < 4)
    delay = 1;
end
tau = 0.4;
%tau = 0.2;
import java.io.*;
import java.awt.*;
if(strcmp(button,'right'))
    key = java.awt.event.KeyEvent.VK_NUMPAD3;
elseif(strcmp(button,'left'))
    key = java.awt.event.KeyEvent.VK_NUMPAD1;
elseif(strcmp(button,'up'))
    key = java.awt.event.KeyEvent.VK_NUMPAD5;
elseif(strcmp(button,'down'))
    key = java.awt.event.KeyEvent.VK_NUMPAD5;
elseif(strcmp(button,'z'))
    key = java.awt.event.KeyEvent.VK_Z;
elseif(strcmp(button,'c'))
    key = java.awt.event.KeyEvent.VK_C;
elseif(strcmp(button,'x'))
    key = java.awt.event.KeyEvent.VK_X;
elseif(strcmp(button,'r'))
    key = java.awt.event.KeyEvent.VK_R;
elseif(strcmp(button,'v'))
    key = java.awt.event.KeyEvent.VK_V;
else
    error('Invalid Button!');
end
for i=1:n
    disp(button);
    pause(delay*tau/2);
    robot.keyPress(key);
    %pause(delay*tau/10);
    pause(0.05);
    robot.keyRelease(key);
    pause(delay*tau/2);
end
end

function [turn] = checkTurn(robot)
c = robot.getPixelColor(966,286);
turn = (getRed(c) == 207 && getBlue(c) == 0 && getGreen(c) == 0);
end

function [EOB] = checkEOB(robot)
c = robot.getPixelColor(987,242);
EOB = (getRed(c) == 0 && getBlue(c) == 0 && getGreen(c) == 41);
end

function [] = attackIteration(robot, tau)
robot.pressButton('left',4);
lastj = 1;
anyAttack = false;
for i=1:5
    monster = scanPlayerData(robot);
    if(monster.atk > 0)
        robot.pressButton('z',1);
        pause(tau);
        if(~anyAttack)
            robot.pressButton('right',4);
            anyAttack = true;
        end
        for j=lastj:5
            oppMonster = scanOpponentData(robot);
            if(oppMonster.star > 0 || j == 5)
                robot.pressButton('z',1);
                pause(tau);
                while(~checkTurn(robot))
                    pause(tau);
                end
                pause(tau);
                if(checkEOB(robot))
                    return
                end
                break
            else
                robot.pressButton('left',1);
            end
        end
        lastj = j;
    end
    if(i<5)
        disp('hue');
        robot.pressButton('right',1);
    end
end

end


%
% function [] = attackIteration(robot)
% for i=1:5
%     success = false;
%     robot.pressButton('z',1);
%     robot.pressButton('right',4);
%     for j=1:5
%         robot.pressButton('z',1);
%         pause(tau);
%         while(~checkTurn(robot))
%             disp('Successful attack');
%             success = true;
%             pause(5*tau);
%             break
%         end
%         if(~success)
%             robot.pressButton('left',1);
%         end
%     end
%     robot.pressButton('right',1);
% end
% end