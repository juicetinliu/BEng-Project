import processing.video.*;
Capture cam;
import gab.opencv.*;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

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
    
    opencv.gray();
    opencv.threshold(int(map(mouseX,0,width,0,255)));
    dst = opencv.getOutput();
  
    contours = opencv.findContours();
    println("found " + contours.size() + " contours");
    
    
    image(cam, 0, 0);
  
  
    noFill();
    strokeWeight(3);
    
    for (Contour contour : contours) {
      stroke(0, 255, 0);
      contour.draw();
      
      stroke(255, 0, 0);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
    }
  }
}
