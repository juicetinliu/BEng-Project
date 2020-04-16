import gab.opencv.*;
import processing.video.*;
Capture cam;

ArrayList<Ring> Rings = new ArrayList<Ring>();
int ringcount = 2;

OpenCV opencv;
PImage cannyFrame,houghFrame;

int[][] hough;
int circlerad = 40;

//vvv PARAMETERS FOR SAMPLING vvv
boolean changecanny = false;
int canny1 = 255, canny2 = 255;
int xyspacing = 2;
int rotspacing = 5;
int checkring = 5;

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
    cam = new Capture(this, cameras[0]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  opencv = new OpenCV(this, cam.width, cam.height);
  
  hough = new int[640][480];
  
  houghFrame = new PImage(640,480);
}

//circlerad = int(map(mouseX,0,width,0,240));
//xyspacing = int(map(mouseX,0,width,1,20));
//rotspacing = int(map(mouseY,0,height,1,60));

void draw() {
  if (cam.available() == true) {
    cam.read();
    opencv.loadImage(cam);
    if(changecanny){
      canny1 = int(map(mouseX,0,width,0,255));
      canny2 = int(map(mouseY,0,height,0,255));
    }
    opencv.findCannyEdges(canny1,canny2);
    //opencv.findCannyEdges(255,255);
    cannyFrame = opencv.getSnapshot();
    resethough();
    
    for(int y = 0; y < 480; y += xyspacing){
      for(int x = 0; x < 640; x += xyspacing){
        for(int th = 0; th < 360; th += rotspacing){
          if(blue(cannyFrame.pixels[y*cam.width+x]) > 0){
            float thrad = radians(th);
            int a = x - int(circlerad * cos(thrad));
            int b = y - int(circlerad * sin(thrad));
            if(a >= 0 && a < 640 && b >= 0 && b < 480){
              hough[a][b] += 4;
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
    
    findRings(ringcount, hough, true);
    
    image(cam, 0, 0);
    //image(cannyFrame, 640, 0);

    //image(cannyFrame, 0, 0);
    image(houghFrame, 640, 0);
    
    //refRing();
    for(Ring thisring:Rings){
      thisring.setAngle();
      thisring.setID();
      thisring.display();
    }
    
    
  }
  hudText();
  pixelColorTool();
}

void refRing(){
  stroke(255,102,0,128);
  strokeWeight(1);
  noFill();
  ellipse(640/2,480/2,circlerad*2,circlerad*2);
  stroke(0,255,102,128);
  ellipse(640/2,480/2,(circlerad-checkring)*2,(circlerad-checkring)*2);
}

void hudText(){
  fill(255);
  textAlign(LEFT,CENTER);
  text(frameRate,10,10);
  if(changecanny){
    fill(255,0,0);
  }
  text(canny1,40,40);
  text(canny2,40,50);
  
  fill(255);
  text(xyspacing,40,20);
  text(rotspacing,40,30);
  text(circlerad,40,60);
  
  textAlign(RIGHT,CENTER);
  text("Can1:",40,40);
  text("Can2:",40,50);
  text("xy:",40,20);
  text("rot:",40,30);
  text("crad:",40,60);
}

void pixelColorTool(){
  textAlign(LEFT,BASELINE);
  if(mouseX < width/2){
    stroke(255);
    fill(0);
    rect(mouseX-40,mouseY-40,40,40);
    fill(255,0,0);
    text(int(red(cam.pixels[mouseY*cam.width+mouseX])),mouseX-35,mouseY-25);
    fill(0,255,102);
    text(int(green(cam.pixels[mouseY*cam.width+mouseX])),mouseX-35,mouseY-15);
    fill(0,102,255);
    text(int(blue(cam.pixels[mouseY*cam.width+mouseX])),mouseX-35,mouseY-5);
  }else{
    stroke(255);
    fill(0);
    rect(mouseX-40,mouseY-15,40,15);
    fill(255);
    text(hough[mouseX-width/2][mouseY],mouseX-35,mouseY-5);
  }
}

void resethough(){
  for(int y = 0; y < 480; y++){
    for(int x = 0; x < 640; x++){
      hough[x][y] = 0;
    }
  }
}


void mousePressed(){
  changecanny = !changecanny;

}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0){
    circlerad = min(circlerad + 1, 480);
  }else{
    circlerad = max(circlerad - 1, 10);
  }
}
