import gab.opencv.*;
import processing.video.*;
Capture cam;

ArrayList<Ring> Rings = new ArrayList<Ring>();
int ringcount = 2;

OpenCV opencv;
PImage cannyFrame,houghFrame;
int swidth, sheight;

int[][] hough;
int circlerad = 24;
float scalex = 2.9739583;
float scaley = 2.6666667;
int offx = -39;
int offy = -29;
boolean finetune = false;
boolean cleanup = false;

//vvv PARAMETERS FOR SAMPLING vvv
boolean changecanny = false;
int canny1 = 255, canny2 = 255;
int xyspacing = 2;
int rotspacing = 5;
int checkring = 3;
int houghThresh = 0;



void setup() {
  //size(640, 480);
  fullScreen();
  //print(width, height);
  
  swidth = 640;
  sheight = 480; //480
  
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
    //960/540
    cam = new Capture(this, swidth, sheight, cameras[0]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  opencv = new OpenCV(this, cam.width, cam.height);
  
  hough = new int[swidth][sheight];
  
  houghFrame = new PImage(swidth, sheight);
}

//circlerad = int(map(mouseX,0,width,0,30));
//xyspacing = int(map(mouseX,0,width,1,20));
//rotspacing = int(map(mouseY,0,height,1,60));

void draw() {
  if (cam.available() == true) {
    //circlerad = int(map(mouseX,0,width,0,30));

    cam.read();
    opencv.loadImage(cam);
    opencv.gray();
    if(changecanny){
      canny1 = min(255,int(map(mouseX,0,width/2,0,255)));
      canny2 = min(255,int(map(mouseY,0,height/2,canny1,255)));
    }
    opencv.findCannyEdges(canny1,canny2);
    //opencv.findCannyEdges(255,255);
    cannyFrame = opencv.getSnapshot();
    resethough();
    
    for(int y = 0; y < sheight; y += xyspacing){
      for(int x = 0; x < swidth; x += xyspacing){
        for(int th = 0; th < 360; th += rotspacing){
          if(blue(cannyFrame.pixels[y*cam.width+x]) > 0){
            float thrad = radians(th);
            int a = x - int(circlerad * cos(thrad));
            int b = y - int(circlerad * sin(thrad));
            if(a >= 0 && a < swidth && b >= 0 && b < sheight){
              hough[a][b] += 4;
              if(a > 0 && a < swidth-1 && b > 0 && b < sheight-1){
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
    
    findRings(ringcount, hough, houghThresh, true);
    background(255);
    if(!cleanup){
      image(cam, 0, height-cam.height/2, cam.width/2, cam.height/2);
      image(cannyFrame, 0, height-cannyFrame.height, cannyFrame.width/2, cannyFrame.height/2);
      image(houghFrame, 0, height-houghFrame.height*3/2, houghFrame.width/2, houghFrame.height/2);
    }
    //image(cannyFrame, 640, 0);

    //image(cannyFrame, 0, 0);
    //image(houghFrame, 0, 0);
    //background(255);
    //refRing();
    for(Ring thisring:Rings){
      thisring.setAngle();
      thisring.setID();
      thisring.display(scalex, scaley , offx, offy, 50);
    }
    
    
  }
  if(!cleanup){
    hudText(color(0));
  }
  //pixelColorTool();
  fill(0);
  textAlign(CENTER,CENTER);
  text("udlr for offset; wasd for scale; c for canny; h to hide; qe for houghThresh", width/2, height-10); 
}

void refRing(){
  stroke(255,102,0,128);
  strokeWeight(1);
  noFill();
  ellipse(640/2,480/2,circlerad*2,circlerad*2);
  stroke(0,255,102,128);
  ellipse(640/2,480/2,(circlerad-checkring)*2,(circlerad-checkring)*2);
}

void hudText(color textcolor){
  fill(textcolor);
  textAlign(LEFT,CENTER);
  text(frameRate,10,10);
  if(changecanny){
    fill(255,0,0);
  }
  text(canny1,40,40);
  text(canny2,40,50);
  
  fill(textcolor);
  text(xyspacing,40,20);
  text(rotspacing,40,30);
  text(circlerad,40,60);
  text(houghThresh,40,70);
  if(finetune){
    fill(255,0,0);
  }
  text(scalex + "," + scaley,40,80);
  text(offx,40,90);
  text(offy,40,100);
  
  fill(textcolor);
  textAlign(RIGHT,CENTER);

  text("xy:",40,20);
  text("rot:",40,30);
  text("Can1:",40,40);
  text("Can2:",40,50);
  text("crad:",40,60);
  text("hthr:",40,70);
  text("scal:",40,80);
  text("offx:",40,90);
  text("offy:",40,100);
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
  for(int y = 0; y < sheight; y++){
    for(int x = 0; x < swidth; x++){
      hough[x][y] = 0;
    }
  }
}


void mousePressed(){
  //changecanny = !changecanny;
  finetune = !finetune;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0){
    circlerad = min(circlerad + 1, min(sheight,swidth));
  }else{
    circlerad = max(circlerad - 1, 1);
  }
}

void keyPressed(){
  print(keyCode);
  if(keyCode == 38){
    if(finetune){
      offy -= 1;
    }else{
      offy -= 10;
    }
  }else if(keyCode == 40){
    if(finetune){
      offy += 1;
    }else{
      offy += 10;
    }
  }else if(keyCode == 37){
    if(finetune){
      offx -= 1;
    }else{
      offx -= 10;
    }
  }else if(keyCode == 39){
    if(finetune){
      offx += 1;
    }else{
      offx += 10;
    }
  }else if(keyCode == 87){ //w
    if(finetune){
      scaley -= 0.001;
    }else{
      scaley -= 0.01;
    }
  }else if(keyCode == 83){//s
    if(finetune){
      scaley += 0.001;
    }else{
      scaley += 0.01;
    }
  }else if(keyCode == 65){//a
    if(finetune){
      scalex -= 0.001;
    }else{
      scalex -= 0.01;
    }
  }else if(keyCode == 68){//d
    if(finetune){
      scalex += 0.001;
    }else{
      scalex += 0.01;
    }
  }else if(keyCode == 67){//c
    changecanny = !changecanny;
  }else if(keyCode == 72){//h
    cleanup = !cleanup;
  }else if(keyCode == 81){//q
    houghThresh = max(0,houghThresh - 1);
  }else if(keyCode == 69){//e
    houghThresh = min(255,houghThresh + 1);
  }
  
}
