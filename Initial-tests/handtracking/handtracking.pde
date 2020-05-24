import gab.opencv.*;
import processing.video.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;
Capture cam;

OpenCV opencv;

int lowerb = 50;
int upperb = 100;
int siz = 1;
PImage src, dst;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

int maxColors = 8;
int[] hues;
int[] colors;
int rangeWidth = 5;

PImage[] outputs;

int colorToChange = -1;

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
    cam = new Capture(this, 640, 480, cameras[2]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  colors = new int[maxColors];
  hues = new int[maxColors];
  
  outputs = new PImage[maxColors];
  
  opencv = new OpenCV(this, cam.width, cam.height);
}


void draw() {
  if (cam.available() == true) {
    //siz = int(map(mouseX,0,width,1,50));
    background(0);
    cam.read();
    opencv.loadImage(cam);
    opencv.useColor();
    
    src = opencv.getSnapshot();
    //opencv.loadImage(src);
    opencv.blur(2);  
    opencv.useColor(HSB);
    detectColors();
    //opencv.setGray(opencv.getH());
    //opencv.dilate();
    //opencv.erode();
    //opencv.blur(2);  
    //opencv.inRange(hueToDetect-huediff, hueToDetect+huediff);
    //dst = opencv.getSnapshot();
    //opencv.gray();
    //opencv.threshold(70);
    //dst = opencv.getOutput();
    //opencv.blur(2);  
    //opencv.gray();
    //opencv.inRange(lowerb, upperb);
    //opencv.dilate();
    //opencv.erode();
    //opencv.findCannyEdges(200,255);
    //opencv.dilate();
    //opencv.erode();
     //dst = opencv.getOutput();
      
    //opencv.dilate();
    //opencv.erode();
    image(src, 0, 0);
    dst = src.copy();
    int counter = 0;
    for (int i=0; i<outputs.length; i++) {
      if (outputs[i] != null) {
        //image(outputs[i], width-src.width/4, i*src.height/4, src.width/4, src.height/4);
        if(counter == 0){
          //image(outputs[i], width/2, 0, src.width, src.height);
          dst = outputs[i].copy();
        }else{
          //image(outputs[i], width/2, 0, src.width, src.height);
          //blend(outputs[i], 0, 0, src.width, src.height, width/2, 0, src.width, src.height, ADD);
          dst.blend(outputs[i], 0, 0, src.width, src.height, 0, 0, src.width, src.height, ADD);
        }
        counter++;
      }
    }
    opencv.loadImage(dst);
    //opencv.blur(int(map(mouseY,height,0,1,20)));  
    //opencv.dilate();
    //opencv.threshold(240);
    //opencv.blur(int(map(mouseY,height,0,1,40)));  
    //opencv.dilate();
    //opencv.blur(int(map(mouseY,height,0,1,20)));  
    //opencv.erode();
    //opencv.
    //opencv.threshold(240);
    //opencv.blur(int(map(mouseY,height,0,1,40)));  
    //opencv.open(7);
    //opencv.close(5);
    
    
    Mat out = opencv.getH().clone();
    
    Imgproc.medianBlur(opencv.getGray(), out, 9);
    
    dst = opencv.getSnapshot(out);
    opencv.loadImage(dst);
    //opencv.close(10);
    
    //opencv.threshold(240);
    //opencv.blur(int(map(mouseY,height,0,1,20)));  
    //opencv.dilate();
    //opencv.threshold(240);
    //opencv.blur(int(map(mouseY,height,0,1,20)));  
    //opencv.dilate();
    //opencv.threshold(240);
    //dst = opencv.getSnapshot();
    image(dst, width/2, 0);
    for (int i=0; i<outputs.length; i++) {
      if (outputs[i] != null) {
        noStroke();
        fill(colors[i]);
        rect(src.width, i*src.height/maxColors, 30, src.height/maxColors);
      }
    }
    
    // Print text if new color expected
    //textSize(20);
    //stroke(255);
    //fill(255);
    
    //if (colorToChange > -1) {
    //  text("click to change color " + colorToChange, 10, 25);
    //} else {
    //  text("press key [1-4] to select color", 10, 25);
    //}
    if(counter == 7){
      contours = opencv.findContours();
    //image(cam, 0, 0);
    //image(dst, cam.width, 0);
    
    //fill(255);
    //ellipse(width/4,height/2,siz,siz);
    //noFill();
    //strokeWeight(3);
    
      for (Contour contour : contours) {
        stroke(0, 255, 0);
        contour.draw();
        
      //  stroke(255, 0, 0);
      //  beginShape();
      //  for (PVector point : contour.getPolygonApproximation().getPoints()) {
      //    vertex(point.x, point.y);
      //  }
      //  endShape();
      }
    }
  }
  fill(255);
  textSize(12);
  text(frameRate,10,10);
}

void detectColors() {
    
  for (int i=0; i<hues.length; i++) {
    
    if (hues[i] <= 0) continue;
    
    opencv.loadImage(src);
    opencv.useColor(HSB);
    
    // <4> Copy the Hue channel of our image into 
    //     the gray channel, which we process.
    opencv.setGray(opencv.getH().clone());
    
    int hueToDetect = hues[i];
    //println("index " + i + " - hue to detect: " + hueToDetect);
    
    // <5> Filter the image based on the range of 
    //     hue values that match the object we want to track.
    opencv.inRange(hueToDetect-rangeWidth/2, hueToDetect+rangeWidth/2);
    //opencv.inRange(hueToDetect, hueToDetect);
    opencv.erode();
    opencv.open(3);
    opencv.close(2);
    //opencv.erode();
    //opencv.erode();
    //opencv.erode();
    //opencv.open(3);
    //opencv.close(3);
    //opencv.dilate();
    //opencv.dilate();
    
    //opencv.erode();
    //Mat out = opencv.getH().clone();
    
    //Imgproc.medianBlur(opencv.getGray(), out, 3);
    //dst = opencv.getSnapshot(out);
    // TO DO:
    // Add here some image filtering to detect blobs better
    
    // <6> Save the processed image for reference.
    outputs[i] = opencv.getSnapshot();
  }
  
  // <7> Find contours in our range image.
  //     Passing 'true' sorts them by descending area.
  //if (outputs[0] != null) {
    
  //  opencv.loadImage(outputs[0]);
  //  contours = opencv.findContours(true,true);
  //}
}

void mousePressed() {
    
  if (colorToChange > -1) {
    //if(mouseX > width/2){
    //  hues[colorToChange-1] = 0;
    //  outputs[colorToChange-1] = null;
    //  return;
    //}
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 0, 180));
    
    colors[colorToChange-1] = c;
    hues[colorToChange-1] = hue;
    
    println("color index " + (colorToChange-1) + ", value: " + hue);
  }
}

void modifyhue(){
  if (colorToChange > -1) {
    if(mouseX > width/2){
      hues[colorToChange-1] = 0;
      outputs[colorToChange-1] = null;
      return;
    }
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 0, 180));
    
    colors[colorToChange-1] = c;
    hues[colorToChange-1] = hue;
    
    println("color index " + (colorToChange-1) + ", value: " + hue);
  }
}

void keyPressed() {
  
  if (key == '1') {
    colorToChange = 1;
    modifyhue();
  } else if (key == '2') {
    colorToChange = 2;
    modifyhue();
  } else if (key == '3') {
    colorToChange = 3;
    modifyhue();
  } else if (key == '4') {
    colorToChange = 4;
    modifyhue();
  }else if (key == '5') {
    colorToChange = 5;
    modifyhue();
  } else if (key == '6') {
    colorToChange = 6;
    modifyhue();
  } else if (key == '7') {
    colorToChange = 7;
    modifyhue();
  } else if (key == '8') {
    colorToChange = 8;
    modifyhue();
  }
}

void keyReleased() {
  colorToChange = -1; 
}

//import gab.opencv.*;
//import processing.video.*;
//Capture cam;

//OpenCV opencv;


//Histogram histogram;

//int lowerb = 50;
//int upperb = 100;

//void setup() {
//  String[] cameras = Capture.list();
//  if (cameras == null) {
//    println("Failed to retrieve the list of available cameras, will try the default...");
//    cam = new Capture(this, 640, 480);
//  } else if (cameras.length == 0) {
//    println("There are no cameras available for capture.");
//    exit();
//  } else {
//    println("Available cameras:");
//    printArray(cameras);
//    cam = new Capture(this, 640, 480, cameras[2]);
//    print(cam.width + " x " + cam.height);
//    cam.start();
//  }
//  opencv = new OpenCV(this, cam.width, cam.height);
//  size(640, 480);
//  opencv.useColor(HSB);
//  opencv.loadImage(cam);
//}

//void draw() {
//  if (cam.available() == true) {
//    cam.read();
//    opencv.loadImage(cam);
    
     
    
//    opencv.setGray(opencv.getH().clone());
//    opencv.inRange(lowerb, upperb);
//    histogram = opencv.findHistogram(opencv.getH(), 255);
  
//    image(cam, 0, 0); 
//    image(opencv.getOutput(), 3*width/4, 3*height/4, width/4,height/4);
  
//    noStroke(); fill(0);
//    histogram.draw(10, height - 230, 400, 200);
//    noFill(); stroke(0);
//    line(10, height-30, 410, height-30);
  
//    text("Hue", 10, height - (textAscent() + textDescent()));
  
//    float lb = map(lowerb, 0, 255, 0, 400);
//    float ub = map(upperb, 0, 255, 0, 400);
  
//    stroke(255, 0, 0); fill(255, 0, 0);
//    strokeWeight(2);
//    line(lb + 10, height-30, ub +10, height-30);
//    ellipse(lb+10, height-30, 3, 3 );
//    text(lowerb, lb-10, height-15);
//    ellipse(ub+10, height-30, 3, 3 );
//    text(upperb, ub+10, height-15);
//  }
//}

//void mouseMoved() {
//  if (keyPressed) {
//    upperb += mouseX - pmouseX;
//  } 
//  else {
//    if (upperb < 255 || (mouseX - pmouseX) < 0) {
//      lowerb += mouseX - pmouseX;
//    }

//    if (lowerb > 0 || (mouseX - pmouseX) > 0) {
//      upperb += mouseX - pmouseX;
//    }
//  }

//  upperb = constrain(upperb, lowerb, 255);
//  lowerb = constrain(lowerb, 0, upperb-1);
//}
