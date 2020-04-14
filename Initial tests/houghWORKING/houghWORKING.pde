import gab.opencv.*;
//import processing.video.*;
//import org.opencv.core.*;
//import org.opencv.core.Point;
//import org.opencv.imgcodecs.Imgcodecs;
//import org.opencv.imgproc.*;

import processing.video.*;
Capture cam;

OpenCV opencv;
PImage cannyFrame;

int[][] hough;
int circlerad;

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
    cam = new Capture(this, 640, 480, cameras[0]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  opencv = new OpenCV(this, cam.width, cam.height);
  hough = new int[640][480];
  circlerad = 50;
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    
    
    opencv.loadImage(cam);
    
    //opencv.findCannyEdges(int(map(mouseX,0,width,0,255)),int(map(mouseY,0,height,0,255)));
    opencv.findCannyEdges(255,255);
    cannyFrame = opencv.getSnapshot();
    resethough();
    
    for(int y = 0; y < 480; y++){
      for(int x = 0; x < 640; x++){
        for(int th = 0; th < 360; th++){
          if(red(cannyFrame.pixels[y*width+x]) > 0){
            float thrad = radians(th);
            int a = x - int(circlerad * cos(thrad));
            int b = y - int(circlerad * sin(thrad));
            if(a >= 0 && a < 640 && b >= 0 && b < 480){
              hough[a][b] ++;
            }
          }
        }
      }
    }
    for(int y = 0; y < 480; y++){
      for(int x = 0; x < 640; x++){
        cannyFrame.pixels[y*width+x] = color(int(map(hough[x][y],0,100,0,255)));
      }
    }
    
    image(cannyFrame, 0, 0);
  }
}

void resethough(){
  for(int y = 0; y < 480; y++){
    for(int x = 0; x < 640; x++){
      hough[x][y] = 0;
    }
  }
}
