import gab.opencv.*;
//import processing.video.*;
//import org.opencv.core.*;
//import org.opencv.core.Point;
//import org.opencv.imgcodecs.Imgcodecs;
//import org.opencv.imgproc.*;

import processing.video.*;
Capture cam;

OpenCV opencv;
PImage cannyFrame,houghFrame;

int[][] hough;
int circlerad;
int cirx = -1;
int ciry = -1;

//vvv PARAMETERS FOR SAMPLING vvv
int xyspacing = 2;
int rotspacing = 5;
int checkring = 10;

void setup() {
  size(1280, 480);
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
  houghFrame = new PImage(640,480);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    
    
    opencv.loadImage(cam);
    
    //opencv.findCannyEdges(int(map(mouseX,0,width,0,255)),int(map(mouseY,0,height,0,255)));
    opencv.findCannyEdges(255,255);
    cannyFrame = opencv.getSnapshot();
    resethough();
    
    //circlerad = int(map(mouseX,0,width,0,240));
    
    //xyspacing = int(map(mouseX,0,width,1,20));
    //rotspacing = int(map(mouseY,0,height,1,60));
    
    for(int y = 0; y < 480; y += xyspacing){
      for(int x = 0; x < 640; x += xyspacing){
        for(int th = 0; th < 360; th += rotspacing){
          if(blue(cannyFrame.pixels[y*cam.width+x]) > 0){
            float thrad = radians(th);
            int a = x - int(circlerad * cos(thrad));
            int b = y - int(circlerad * sin(thrad));
            if(a >= 0 && a < 640 && b >= 0 && b < 480){
              hough[a][b] += 2;
              if(a > 0 && a < 639 && b > 0 && b < 479){
                hough[a-1][b] ++;
                hough[a+1][b] ++;
                hough[a][b-1] ++;
                hough[a][b+1] ++;
              }
            }
          }
        }
      }
    }
    
    int maxvote = 0;
    //int maxvote = int(map(mouseX,0,width,0,200));
    
    //WHILE NUMBER OF CIRCLES LESS THAN WANTED NUMBER 
    //-> search pixel array 
      //-> find max pixel
      //-> record it if it is not within the radius of the current max circle.
      //-> repeat
    
    cirx = -1;
    ciry = -1;
    houghFrame.loadPixels();
    for(int y = 0; y < 480; y++){
      for(int x = 0; x < 640; x++){
        houghFrame.pixels[y*cam.width+x] = color(int(map(hough[x][y],0,200,0,255)));
        if(hough[x][y] > maxvote){
          cirx = x;
          ciry = y;
          maxvote = hough[x][y];
        }
      }
    }
    
    houghFrame.updatePixels();
    image(cannyFrame, 0, 0);
    
    image(houghFrame, 640, 0);
    
    stroke(255,102,0,128);
    strokeWeight(1);
    noFill();
    ellipse(640/2,480/2,circlerad*2,circlerad*2);
    stroke(0,255,102,128);
    ellipse(640/2,480/2,(circlerad-checkring)*2,(circlerad-checkring)*2);
    
    //strokeWeight(5);
    if(cirx != -1 && ciry != -1){
      stroke(255,0,0);
      ellipse(cirx,ciry,circlerad*2,circlerad*2);
      stroke(0,255,0);
      ellipse(cirx,ciry,(circlerad-checkring)*2,(circlerad-checkring)*2);
      fill(255,0,0);
      text(maxvote,cirx,ciry);
      int maxgreen = 0;
      int greenang = -1;
      for(int th = 0; th < 360; th += 1){
        float thrad = radians(th);
        int a = cirx - int((circlerad-checkring) * cos(thrad));
        int b = ciry - int((circlerad-checkring) * sin(thrad));
        if(a >= 0 && a < 640 && b >= 0 && b < 480){
          if(green(cam.pixels[b*cam.width+a]) > maxgreen){
            maxgreen = int(green(cam.pixels[b*cam.width+a]));
            greenang = th;
          }
        }
      }
      if(greenang != -1){
        float greenangrad = radians(greenang);
        pushMatrix();
        translate(cirx,ciry);
        rotate(greenangrad+PI/2);
        stroke(0,255,0);
        line(0,0,0,100);
        fill(0,255,0);
        text(maxgreen,0,100);
        popMatrix();
      }
    }
  }
  fill(255);
  text(frameRate,10,10);
  text(xyspacing,10,20);
  text(rotspacing,10,30);
  fill(255,0,0);
  text(red(cam.pixels[mouseY*cam.width+mouseX]),mouseX,mouseY+10);
  fill(0,255,0);
  text(green(cam.pixels[mouseY*cam.width+mouseX]),mouseX,mouseY);
  fill(0,0,255);
  text(blue(cam.pixels[mouseY*cam.width+mouseX]),mouseX,mouseY-10);
}

void resethough(){
  for(int y = 0; y < 480; y++){
    for(int x = 0; x < 640; x++){
      hough[x][y] = 0;
    }
  }
}
