clear; clc;
%%
runyugimod(3);
pause(3)
img = screencapture(0, 'Position', [0 0 1440 900]);

pause(3);
import java.io.*;
import java.awt.*;
robot = Robot;
tool = Toolkit.getDefaultToolkit();

    %img = robot.createScreenCapture(Rectangle(404,205,639,479));
    img = robot.createScreenCapture(java.awt.Rectangle(tool.getScreenSize()));
    pic = java_img2mat(img);
    screen = rgb2gray(pic);
    
    
    name = screen(425:448,30:420);
    nameR = screen((425:448) - 175,30:420);
    atk = screen(423:436,444:502);
    def = screen(439:452,444:502);    
    attr1 = screen(420:455,548:575);
    attr2 = screen(420:455,580:613);
    atkR = screen((423:436) - 175,442:502);
    defR = screen((439:452) - 175,442:502);    
    attrR = screen((420:455) - 175,548:613);
    
    

    OCR = ocr(def, 'CharacterSet', '0123456789', 'TextLayout', 'Line');
    