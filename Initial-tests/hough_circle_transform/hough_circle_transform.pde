import gab.opencv.*;
import processing.video.*;
import java.util.*;

Capture cam;

OpenCV opencv;
PImage cannyFrame;

ArrayList<Hough> houghs = new ArrayList<Hough>();

int[][][] hough;
int minrad, maxrad, circn = 10;

void setup() {
  size(640, 480);
  String[] cameras = Capture.list();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);
    cam = new Capture(this, cameras[0]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  opencv = new OpenCV(this, cam.width, cam.height);
  minrad = 50;
  maxrad = 51;
  hough = new int[640][480][maxrad-minrad];
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    opencv.loadImage(cam);
    opencv.findCannyEdges(20,75);
    cannyFrame = opencv.getSnapshot();
    
    resetHoughs(houghs);

    for(int y = 0; y < 480; y++){
      for(int x = 0; x < 640; x++){
        for(int r = minrad; r < maxrad; r++){
          for(int th = 0; th < 360; th++){
            if(red(cannyFrame.pixels[y*width+x]) > 0){
              float thrad = radians(th);
              int a = x - r * int(cos(thrad));
              int b = y - r * int(sin(thrad));
              if(a >= 0 && a < 640 && b >= 0 && b < 480){
                if(!addToHough(houghs,a,b,r,1)){
                  houghs.add(new Hough(a,b,r,1));
                }
              }
            }
          }
        }
      }
    }
    houghs = sortHoughs(houghs);
    
    image(cannyFrame, 0, 0);
    for(int h = 0; h < circn; h++){
      Hough thish = houghs.get(h);
      thish.display();
    }
  }
}

//void resethough(){
//  for(int y = 0; y < 480; y++){
//    for(int x = 0; x < 640; x++){
//      for(int r = minrad; r < maxrad; r++){
//        hough[x][y][r-minrad] = 0;
//      }
//    }
//  }
//}
  //For each pixel(x,y)
  //  For each radius r = 10 to r = 60 // the possible radius
  //    For each theta t = 0 to 360  // the possible  theta 0 to 360 
  //       a = x – r * cos(t * PI / 180); //polar coordinate for center
  //       b = y – r * sin(t * PI / 180);  //polar coordinate for center 
  //       A[a,b,r] +=1; //voting
  //    end
  //  end
  //end



//void draw() {
//  if (cam.available() == true) {
//    cam.read();
//    loadPixels();
//    for (int y = kersize; y < cam.height - kersize; y++ ){
//      for (int x = kersize; x < cam.width - kersize; x++ ){
//        float sum = 0;
//        for (int ky = -kersize; ky <= kersize; ky++) {
//          for (int kx = -kersize; kx <= kersize; kx++) {
//            // Calculate the adjacent pixel for this kernel point
//            int pos = (y + ky)*cam.width + (x + kx);
//            color currColor = cam.pixels[pos];
//            // Extract the red, green, and blue components from current pixel
//            int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
//            int currG = (currColor >> 8) & 0xFF;
//            int currB = currColor & 0xFF;
//            float val = currR + currG + currB;
//            // Multiply adjacent pixels based on the kernel values
//            sum += (kernelx[ky+kersize][kx+kersize] + kernely[ky+kersize][kx+kersize]) * val / 6;
//          }
//        }
//        pixels[y*cam.width + x] = color(sum);
//      }
//    }
//    updatePixels();
//  //image(cam, 0, 0, width, height);
//  }
//}
