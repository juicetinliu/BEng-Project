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
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    
    
    opencv.loadImage(cam);
    
    opencv.findCannyEdges(int(map(mouseX,0,width,0,255)),int(map(mouseY,0,height,0,255)));
    //opencv.findCannyEdges(20,75);
    cannyFrame = opencv.getSnapshot();
    
    image(cannyFrame, 0, 0);
  }
}
        
