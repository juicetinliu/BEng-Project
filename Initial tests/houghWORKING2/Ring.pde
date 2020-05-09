class Ring{
  int x, y;
  int id, rotint;
  float rotation;
  int houghVote, rotVote;
  
  ArrayList<PVector> poshist = new ArrayList<PVector>();
  int tolerance, histsize;
  
  Ring(int x, int y, int vote){
    this.x = x;
    this.y = y;
    this.rotation = 0;
    this.id = 0;
    this.houghVote = vote;
    this.histsize = 5;
    this.tolerance = 3;
  }
  
  void display(float scalex, float scaley, int offx, int offy, int plusrad){
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
    stroke(0);
    noFill();
    ellipse(x,y,circlerad + plusrad,circlerad + plusrad);
    
    pushMatrix();
    translate(x,y);
    rotate(rotation+PI/2);
    fill(0);
    noStroke();
    //stroke(255,0,0);
    ellipse(0,(circlerad + plusrad)/2,circlerad/10,circlerad/10);
    //line(0,(circlerad + plusrad)/2,0,-(circlerad + plusrad)/2);
    popMatrix();
    //strokeWeight(10);
    //stroke(255);
    //ellipse(x,y,circlerad + plusrad,circlerad + plusrad);
    popMatrix();
  }
  
  void setPos(int x, int y, int vote){
    this.x = x;
    this.y = y;
    this.houghVote = vote;
  }
  
  void setAngle(){
    int greenthresh = 80;
    for(int th = 0; th < 360; th += 1){
      float thrad = radians(th);
      int a = x - int((circlerad-checkring) * cos(thrad));
      int b = y - int((circlerad-checkring) * sin(thrad));
      if(a >= 0 && a < swidth && b >= 0 && b < sheight){
        if(green(cam.pixels[b*cam.width+a]) > greenthresh){
          //maxgreen = int(green(cam.pixels[b*cam.width+a]));
          rotation = thrad;
          rotint = th;
          rotVote = greenthresh;
          return;
        }
      }
    }
    
  }
  void setID(){
    int idout = 0;
    int redthresh = 80;
    for(int bt = 0; bt < 3; bt += 1){
      float thrad = radians((1+bt)*90)+rotation;
      int a = x - int((circlerad-checkring) * cos(thrad));
      int b = y - int((circlerad-checkring) * sin(thrad));
      if(a >= 0 && a < swidth && b >= 0 && b < sheight){
        if(red(cam.pixels[b*cam.width+a]) > redthresh){
          idout += pow(2,bt);
        }
      }else{
        id = -1;
        return;
      }
    }
    id = idout;
  }
}

boolean findRings(int expectedRings, int[][] houghar, int houghthresh, boolean showHough){
  Rings.clear();
  if(showHough){
    houghFrame.loadPixels();
  }
  int noRings = expectedRings - 1;
  int maxvote = houghthresh;
  int cirx = -1;
  int ciry = -1;
  for(int y = 0; y < sheight; y++){
    for(int x = 0; x < swidth; x++){
      if(showHough){
        houghFrame.pixels[y*cam.width+x] = color(int(map(houghar[x][y],0,200,0,255)));
      }
      
      if(hough[x][y] > maxvote){
        cirx = x;
        ciry = y;
        maxvote = hough[x][y];
      }
    }
  }
  if(cirx != -1 || ciry != -1){
    Rings.add(new Ring(cirx, ciry, maxvote));
  }
  
  while(noRings > 0){
    int wmaxvote = houghthresh;
    int wcirx = -1;
    int wciry = -1;
    for(int y = 0; y < sheight; y++){
      for(int x = 0; x < swidth; x++){
        for(Ring thisr:Rings){
          if(dist(x,y,thisr.x,thisr.y) > circlerad * 1.25){
            if(hough[x][y] > wmaxvote){
              wcirx = x;
              wciry = y;
              wmaxvote = hough[x][y];
            }
          }
        }
      }
    }
    if(wcirx != -1 || wciry != -1){
      Rings.add(new Ring(wcirx, wciry, maxvote));
    }
    noRings -= 1;
  }
  
  if(showHough){
    houghFrame.updatePixels();
  }
  
  return true;
}

float limdegrees(float indegrees){ //limits degrees to 0 - 360
  if(indegrees > 360){
    return indegrees % 360;
  }else if(indegrees < 0){
      return indegrees % 360 + 360;
  }else{
    return indegrees;
  }
}

float limradians(float inrads){  //limits radians to 0 - 2*PI
  if(inrads > 2*PI){
    return inrads % (2*PI);
  }else if(inrads < 0){
      return inrads % (2*PI) + 2*PI;
  }else{
    return inrads;
  }
}
