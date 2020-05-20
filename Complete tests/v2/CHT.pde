

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

void houghSetup() {
  //size(640, 480);
  //fullScreen();
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
    println(cam.width + " x " + cam.height);
    cam.start();
  }
  println("Cam done");
  opencv = new OpenCV(this, cam.width, cam.height);
  println("OpenCV done");
  hough = new int[swidth][sheight];
  
  houghFrame = new PImage(swidth, sheight);
  
  Rings.add(new Ring(0,0,1));
  Rings.add(new Ring(0,0,2));
  Rings.add(new Ring(0,0,3));
  ringcount = Rings.size();
  println("done Hough");
}

void houghDraw() {
  if (cam.available() == true){
    cam.read();
    opencv.loadImage(cam);
    opencv.gray();
    opencv.findCannyEdges(canny1,canny2);
    cannyFrame = opencv.getSnapshot();
    resetHough();
    
    voteHough();
    
    bigringno = findRings(ringcount, hough, houghThresh, true);
    matchRingPuck();
    //background(255);
    //refRing(scalex,scaley);
    for(Ring thisring:Rings){
      thisring.display(scalex, scaley , offx, offy, 50);
    }
  }
}

void matchRingPuck(){
  for(int i = 0; i < pucks.size();i++){
    Ring thisring = Rings.get(i);
    if(thisring.found){
      Puck thispuck = pucks.get(i);
      thispuck.CHTRotate(thisring.rotation);
      thispuck.CHTMove(thisring.x,thisring.y);
    }
  }
}
//void refRing(float scalex, float scaley){
//  pushMatrix();
//  translate(mouseX,mouseY);
//  scale(scalex,scaley);
//  stroke(255,102,0,128);
//  strokeWeight(1);
//  noFill();
//  ellipse(0,0,circlerad*2,circlerad*2);
//  stroke(0,255,102,128);
//  ellipse(0,0,(circlerad-checkring)*2,(circlerad-checkring)*2);
//  popMatrix();
//}

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

void loadValues(){
  
  String[] lines = loadStrings("CHTprefs.txt");
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

class Ring{
  int x, y;
  int id, rotint;
  float rotation;
  int houghVote, rotVote;
  boolean found = false;
  
  //ArrayList<PVector> poshist = new ArrayList<PVector>();
  //int tolerance, histsize;
  
  Ring(int x, int y, int id){
    this.x = x;
    this.y = y;
    this.rotation = 0;
    this.id = id;
    this.houghVote = 0;
    //this.histsize = 5;
    //this.tolerance = 3;
  }
  
  void display(float scalex, float scaley, int offx, int offy, int plusrad){
    if(found){
      //strokeWeight(1);
      //stroke(255,0,0);
      //noFill();
      //ellipse(x,y,circlerad*2,circlerad*2);
      
      //stroke(0,255,0);
      //ellipse(x,y,(circlerad-checkring)*2,(circlerad-checkring)*2);
      
      //fill(255,0,0);
      //text(id,x,y);
      
      //pushMatrix();
      //translate(x,y);
      //rotate(rotation+PI/2);
      //stroke(0,255,0);
      //line(0,0,0,100);
      
      //fill(0,255,0);
      //text(rotVote,0,100);
      //popMatrix();
      pushMatrix();
      translate(offx,offy);
      scale(scalex, scaley);
      strokeWeight(1);
      stroke(0,0,255);
      noFill();
      ellipse(x,y,circlerad + plusrad,circlerad + plusrad);
      
      pushMatrix();
      translate(x,y);
      rotate(rotation+PI/2);
      fill(0,0,255);
      noStroke();
      //stroke(255,0,0);
      ellipse(0,(circlerad + plusrad)/2,circlerad/5,circlerad/5);
      //line(0,(circlerad + plusrad)/2,0,-(circlerad + plusrad)/2);
      popMatrix();
      //strokeWeight(10);
      //stroke(255);
      //ellipse(x,y,circlerad + plusrad,circlerad + plusrad);
      //text(houghVote,x,y);
      popMatrix();
    }
    
  }
  
  void setpri(int x, int y, float rotation, int id, int maxvote){
    this.x = x;
    this.y = y;
    this.houghVote = maxvote;
    this.rotation = rotation;
    this.id = id;
  }
  
  void found(){
    found = true;
  }
  
  void unfound(){
    found = false;
  }
}


float checkRot(int x, int y){
  int greenthresh = 80;
  for(int th = 0; th < 360; th += 1){
    float thrad = radians(th);
    int a = x - int((circlerad-checkring) * cos(thrad));
    int b = y - int((circlerad-checkring) * sin(thrad));
    if(a >= 0 && a < swidth && b >= 0 && b < sheight){
      if(green(cam.pixels[b*cam.width+a]) > greenthresh){
        return thrad;
      }
    }
  }
  return -1;
}


int checkID(int x, int y, float rotation){
  int idout = 0;
  int redthresh = 80;
  if(rotation == -1){
    return -1;
  }
  for(int bt = 0; bt < 3; bt += 1){
    boolean foundred = false;
    for(int change = -5; change <= 5; change++){
      if(!foundred){
        float thrad = radians((1+bt)*90+change)+rotation;
        int a = x - int((circlerad-checkring) * cos(thrad));
        int b = y - int((circlerad-checkring) * sin(thrad));
        if(a >= 0 && a < swidth && b >= 0 && b < sheight){
          if(red(cam.pixels[b*cam.width+a]) > redthresh){
            idout += pow(2,bt);
            foundred = true;
          }
        }else{
          return -1;
        }
      }
    }
  }
  if(idout != 0){
    return idout;
  }else{
    return -1;
  }
}

int findRings(int expectedRings, int[][] houghar, int houghthresh, boolean showHough){
  //Rings.clear();
  for(Ring thisr:Rings){
    thisr.unfound();
  }
  if(showHough){
    houghFrame.loadPixels();
  }
  boolean onefound = false;
  for(int noRings = 0; noRings < Rings.size(); noRings++){
    int maxvote = houghthresh;
    int cirx = -1;
    int ciry = -1;
    for(int y = 0; y < sheight; y++){
      for(int x = 0; x < swidth; x++){
        if(showHough){
          int thishough = houghar[x][y];
            if(thishough < houghthresh){
              houghFrame.pixels[y*cam.width+x] = 0;
            }else{
              houghFrame.pixels[y*cam.width+x] = color(int(map(houghar[x][y],houghthresh,200,0,255)));
            }
        }
        if(onefound){
          boolean outofcirc = true;
          for(Ring thisr:Rings){
            if(thisr.found){
              if(dist(x,y,thisr.x,thisr.y) < circlerad){
                outofcirc = false;
              }
            }
          }
          if(outofcirc){
            if(hough[x][y] > maxvote){
              cirx = x;
              ciry = y;
              maxvote = hough[x][y];
            }
          }
        }else{
          if(hough[x][y] > maxvote){
            cirx = x;
            ciry = y;
            maxvote = hough[x][y];
          }
        }
      }
    }
    if(cirx != -1 && ciry != -1){
      //stroke(255,0,0);
      //strokeWeight(1);
      //noFill();
      //ellipse(cirx,ciry, 50,50);
      float rrot = checkRot(cirx,ciry);
      int rid = checkID(cirx,ciry,rrot);
      println(cirx + "," + ciry + ":" + rrot + "," + rid);
      if(rid != -1 || rrot != -1){
        for(Ring thisr:Rings){
          if(thisr.id == rid){
            thisr.setpri(cirx,ciry, rrot, rid, maxvote);
            thisr.found();
            expectedRings --;
            onefound = true;
          }
        }
      //}else{
      //  noRings --;
      }
        
    }
  }
  
  if(showHough){
    houghFrame.updatePixels();
  }
  
  return expectedRings;
}
