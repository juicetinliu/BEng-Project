class Ring{
  int x, y;
  int id, rotint;
  float rotation;
  int houghVote, rotVote;
  boolean found = false;
  
  ArrayList<PVector> poshist = new ArrayList<PVector>();
  int tolerance, histsize;
  
  Ring(int x, int y, int id){
    this.x = x;
    this.y = y;
    this.rotation = 0;
    this.id = id;
    this.houghVote = 0;
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
      translate(x,y);
      strokeWeight(1);
      if(found){
        stroke(0,0,255);
      }else{
        stroke(0,255,255);
      }
      noFill();
      ellipse(0,0,circlerad + plusrad,circlerad + plusrad);
      
      pushMatrix();
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
    //}
    
  }
  
  void setpri(int x, int y, float rotation, int id, int maxvote){
    this.x = x;
    this.y = y;
    this.houghVote = maxvote;
    this.rotation = rotation;
    this.id = id;
  }
  
  //void setAngle(){
  //  int greenthresh = 80;
  //  for(int th = 0; th < 360; th += 1){
  //    float thrad = radians(th);
  //    int a = x - int((circlerad-checkring) * cos(thrad));
  //    int b = y - int((circlerad-checkring) * sin(thrad));
  //    if(a >= 0 && a < swidth && b >= 0 && b < sheight){
  //      if(green(cam.pixels[b*cam.width+a]) > greenthresh){
  //        //maxgreen = int(green(cam.pixels[b*cam.width+a]));
  //        rotation = thrad;
  //        rotint = th;
  //        rotVote = greenthresh;
  //        return;
  //      }
  //    }
  //  }
    
  //}
  //void setID(){
  //  int idout = 0;
  //  int redthresh = 80;
  //  for(int bt = 0; bt < 3; bt += 1){
  //    float thrad = radians((1+bt)*90)+rotation;
  //    int a = x - int((circlerad-checkring) * cos(thrad));
  //    int b = y - int((circlerad-checkring) * sin(thrad));
  //    if(a >= 0 && a < swidth && b >= 0 && b < sheight){
  //      if(red(cam.pixels[b*cam.width+a]) > redthresh){
  //        idout += pow(2,bt);
  //      }
  //    }else{
  //      id = -1;
  //      return;
  //    }
  //  }
  //  id = idout;
  //}
  void found(){
    found = true;
  }
  
  void unfound(){
    found = false;
  }
}


float checkRot(int x, int y){
  int greenthresh = 100;
  for(int th = 0; th < 360; th += 1){
    float thrad = radians(th);
    int a = x - int((circlerad-checkring) * cos(thrad));
    int b = y - int((circlerad-checkring) * sin(thrad));
    if(a >= 0 && a < swidth && b >= 0 && b < sheight){
      float gree = green(cam.pixels[b*cam.width+a]);
      float re = red(cam.pixels[b*cam.width+a]);
      float blu = blue(cam.pixels[b*cam.width+a]);
      if(gree > greenthresh && gree > re && gree > blu){
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
          float gree = green(cam.pixels[b*cam.width+a]);
          float re = red(cam.pixels[b*cam.width+a]);
          float blu = blue(cam.pixels[b*cam.width+a]);
          if(re > redthresh && re > gree && re > blu){
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
        if(showHough && noRings == 0){
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
      if(rrot != -1){
        int rid = checkID(cirx,ciry,rrot);
        if(rid != -1){
          for(Ring thisr:Rings){
            //println(cirx + "," + ciry + ":" + rrot + "," + rid);
            if(thisr.id == rid){
              thisr.found();
              thisr.setpri(cirx,ciry, rrot, rid, maxvote);
              expectedRings--;
              onefound = true;
            }
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
