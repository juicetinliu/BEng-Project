class Ring{
  int x, y;
  int id, rotint;
  float rotation;
  int houghVote, rotVote;
  
  
  Ring(int x, int y, int vote){
    this.x = x;
    this.y = y;
    this.rotation = 0;
    this.id = 0;
    this.houghVote = vote;
  }
  
  void display(){
    strokeWeight(1);
    stroke(255,0,0);
    noFill();
    ellipse(x,y,circlerad*2,circlerad*2);
    
    stroke(0,255,0);
    ellipse(x,y,(circlerad-checkring)*2,(circlerad-checkring)*2);
    
    fill(255,0,0);
    text(id,x,y);
    
    pushMatrix();
    translate(x,y);
    rotate(rotation+PI/2);
    stroke(0,255,0);
    line(0,0,0,100);
    
    fill(0,255,0);
    text(rotVote,0,100);
    popMatrix();
  }
  
  void setAngle(){
    int greenthresh = 80;
    for(int th = 0; th < 360; th += 1){
      float thrad = radians(th);
      int a = x - int((circlerad-checkring) * cos(thrad));
      int b = y - int((circlerad-checkring) * sin(thrad));
      if(a >= 0 && a < 640 && b >= 0 && b < 480){
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
    //int[] bits = new int[3];
    int redthresh = 80;
    for(int bt = 0; bt < 3; bt += 1){
      float thrad = radians((1+bt)*90)+rotation;
      int a = x - int((circlerad-checkring) * cos(thrad));
      int b = y - int((circlerad-checkring) * sin(thrad));
      stroke(255,0,0);
      strokeWeight(1);
      line(x,y,a,b);
      if(a >= 0 && a < 640 && b >= 0 && b < 480){
        if(red(cam.pixels[b*cam.width+a]) > redthresh){
          //bits[bt] = 1;
          idout += pow(2,bt);
        }else{
          //bits[bt] = 0;
        }
      }else{
        id = -1;
        return;
        //bits[bt] = -1;
      }
    }
    id = idout;
  }
}

boolean findRings(int expectedRings, int[][] houghar, boolean showHough){
  Rings.clear();
  if(showHough){
    houghFrame.loadPixels();
  }
  int noRings = expectedRings - 1;
  int maxvote = 0;
  int cirx = -1;
  int ciry = -1;
  for(int y = 0; y < 480; y++){
    for(int x = 0; x < 640; x++){
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
    int wmaxvote = 0;
    int wcirx = -1;
    int wciry = -1;
    for(int y = 0; y < 480; y++){
      for(int x = 0; x < 640; x++){
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
