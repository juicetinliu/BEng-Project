import gab.opencv.*;
import processing.video.*;
Capture cam;

ArrayList<Ring> Rings = new ArrayList<Ring>();
int ringcount, bigringno = 0;

OpenCV opencv;
PImage cannyFrame,houghFrame;
int swidth, sheight;

int[][] hough;
int circlerad = 23;
float scalex = 3.323958;
float scaley = 2.9966664;
int offx = -209;
int offy = -289;
boolean finetune = false;
boolean cleanup = false;

//vvv PARAMETERS FOR SAMPLING vvv
boolean changecanny = false;
int canny1 = 255, canny2 = 255;
int xyspacing = 2;
int rotspacing = 5;
int checkring = 2;
int houghThresh = 0;

void setup() {
  //size(640, 480);
  fullScreen();
  //print(width, height);
  
  swidth = 720;
  sheight = 540; //480
  loadValues();
  //swidth = 640;
  //sheight = 480; //480
  
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
    cam = new Capture(this, swidth, sheight, cameras[1]);
    print(cam.width + " x " + cam.height);
    cam.start();
  }
  
  opencv = new OpenCV(this, cam.width, cam.height);
  
  hough = new int[swidth][sheight];
  
  houghFrame = new PImage(swidth, sheight);
  
  Rings.add(new Ring(0,0,1));
  Rings.add(new Ring(0,0,2));
  Rings.add(new Ring(0,0,3));
  ringcount = Rings.size();
}

void draw() {
  if (cam.available() == true){
    if(cleanup){
      noCursor();
    }else{
      cursor();
    }
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
    resetHough();
    
    voteHough();
    
    bigringno = findRings(ringcount, hough, houghThresh, true);
    background(255);
    if(!cleanup){
      image(cam, 0, height-cam.height/2, cam.width/2, cam.height/2);
      image(cannyFrame, 0, height-cannyFrame.height, cannyFrame.width/2, cannyFrame.height/2);
      image(houghFrame, 0, height-houghFrame.height*3/2, houghFrame.width/2, houghFrame.height/2);
    }
    //image(cannyFrame, 640, 0);

    //image(cam, offx, offy, cam.width*scalex, cam.height*scaley);
    //image(houghFrame, 0, 0);
    //background(255);
    refRing(scalex,scaley);
    for(Ring thisring:Rings){
      thisring.display(scalex, scaley , offx, offy, 50);
    }
    
    
  }
  if(!cleanup){
    hudText(color(0));
    pixelColorTool();
  }
  fill(0);
  textAlign(CENTER,CENTER);
  text("udlr for offset; wasd for scale; c for canny; h to hide; qe for houghThresh; space/r to save/reset; zx for checkring", width/2, height-10);
  textAlign(RIGHT,CENTER);
  text(bigringno,width,height-10);
}

void refRing(float scalex, float scaley){
  pushMatrix();
  translate(mouseX,mouseY);
  scale(scalex,scaley);
  stroke(255,102,0,128);
  strokeWeight(1);
  noFill();
  ellipse(0,0,circlerad*2,circlerad*2);
  stroke(0,255,102,128);
  ellipse(0,0,(circlerad-checkring)*2,(circlerad-checkring)*2);
  popMatrix();
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
  text(checkring,40,70);
  text(houghThresh,40,110);
  
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
  text("check:",40,70);
  text("hthr:",40,110);
  text("scal:",40,80);
  text("offx:",40,90);
  text("offy:",40,100);
}

void pixelColorTool(){
  textAlign(LEFT,BASELINE);
  loadPixels();
  stroke(0);
  color pixc = pixels[mouseY*width+mouseX];
  fill(pixc);
  rect(mouseX-41,mouseY-41,40,40);
  fill(255,0,0);
  text(int(red(pixc)),mouseX-36,mouseY-26);
  fill(0,255,102);
  text(int(green(pixc)),mouseX-36,mouseY-16);
  fill(0,102,255);
  text(int(blue(pixc)),mouseX-36,mouseY-6);
}

void resetHough(){
  for(int y = 0; y < sheight; y++){
    for(int x = 0; x < swidth; x++){
      hough[x][y] = 0;
    }
  }
}

void voteHough(){
  for(int y = 0; y < sheight; y += xyspacing){
    for(int x = 0; x < swidth; x += xyspacing){
      for(int th = 0; th < 360; th += rotspacing){
        if(blue(cannyFrame.pixels[y*cam.width+x]) > 0){
          float thrad = radians(th);
          int a = x - int(circlerad * cos(thrad));
          int b = y - int(circlerad * sin(thrad));
          if(a >= 0 && a < swidth && b >= 0 && b < sheight){
            hough[a][b] += 9;
            if(a > 0 && a < swidth-1 && b > 0 && b < sheight-1){
              hough[a-1][b] += 4;
              hough[a+1][b] += 4;
              hough[a][b-1] += 4;
              hough[a][b+1] += 4;
              hough[a-1][b-1] += 1;
              hough[a+1][b-1] += 1;
              hough[a-1][b+1] += 1;
              hough[a+1][b+1] += 1;
              //if(a > 1 && a < swidth-2 && b > 1 && b < sheight-2){
              //  hough[a-2][b] += 1;
              //  hough[a+2][b] += 1;
              //  hough[a][b-2] += 1;
              //  hough[a][b+2] += 1;
              //}
            }
          }
        }
      }
    }
  }
}

void saveValues(){
  StringList linesout = new StringList();
  
  linesout.append(str(circlerad));
  linesout.append(str(checkring));
  linesout.append(str(houghThresh));
  linesout.append(str(scalex));
  linesout.append(str(scaley));
  linesout.append(str(offx));
  linesout.append(str(offy));
  String[] string = new String[1];
  
  String savepath = "lines.txt";
  saveStrings(savepath, linesout.array(string));
}

void loadValues(){
  
  String[] lines = loadStrings("lines.txt");
  int linctr = 0;
  circlerad = int(lines[linctr]);
  linctr++;
  checkring = int(lines[linctr]);
  linctr++;
  houghThresh = int(lines[linctr]);
  linctr++;
  scalex = float(lines[linctr]);
  linctr++;
  scaley = float(lines[linctr]);
  linctr++;
  offx = int(lines[linctr]);
  linctr++;
  offy = int(lines[linctr]);
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
  }else if(keyCode == 32){//SPACE
    saveValues();
  }else if(keyCode == 82){//r
    loadValues();
  }else if(keyCode == 90){//z
    checkring = max(0,checkring - 1);
  }else if(keyCode == 88){//x
    checkring = min(10,checkring + 1);
  }
}
