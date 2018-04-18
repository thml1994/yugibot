function image = java_img2mat(javaimg)
import java.io.*;
import java.awt.*;    

      H = javaimg.getHeight;
      W = javaimg.getWidth;

  image = uint8(zeros([H,W,3]));
  pixelsData = uint8(javaimg.getData.getPixels(0,0,W,H,[]));
  for i = 1 : H
  base = (i-1)*W*3+1;
  image(i,1:W,:) = deal(reshape(pixelsData(base:(base+3*W-1)),3,W)');
  end
end