class Zone{
  int id;
  String label;
  int type; //square - 0;circle - 1
  float x, y, w, h;
  
  Zone(int id, String label, int type, float x, float y, float w, float h){
    this.id = id;
    this.type = type;
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
  }
  
  void display(color fcolor, boolean fok, color scolor, boolean sok){
    if(fok){
      fill(fcolor);
    }else{
      noFill();
    }
    if(sok){
      stroke(scolor);
      strokeWeight(1);
    }else{
      noStroke();
    }
    if(type == 0){
      rectMode(CENTER);
      rect(x, y, w, h);
    }else if(type == 1){
      ellipse(x,y,w,h);
    }    
  }
  
  boolean puckWithin(float px, float py){
    if(type == 0){
      return pointinrect(px, py, x, y, w, h);
    }else if(type == 1){
      return pointincircle(px, py, x, y, h);
    }else{
      return false;
    }
  }
}

class Runzone extends Zone{
  int zoneclock, zoneanims, zoneanidur = 100;
  int zonebarclock, zonebanims, zonebanidur = 15;
  int state; //0 - idle, 1 - setting MASTERPUCK, 2 - ready with MASTERPUCK, 3 - turning with MASTERPUCK
  float sliderlength;
  Puck ThePuck = null;
  
  Runzone(int id, String label, int type, float x, float y, float w, float h){
    super(id, label, type, x, y, w, h);
    this.zoneanims = millis();
    this.zoneclock = 0;
    this.zonebanims = millis();
    this.zonebarclock = 0;
    this.state = 0;
    this.sliderlength = w;
  }
  
  void run(){
    switch(state){
      case 0:{
        if(ThePuck == null){
          if(zonebarclock > 0){
            if(mspassed(zonebanims,5)){
              zonebarclock--;
              zonebanims = millis();
            }
          }else{
            if(zoneclock > 0){
              if(mspassed(zoneanims,5)){
                zoneclock--;
                zoneanims = millis();
              }
            }
          }
        }else{
          state = 1;
        }
        break;
      }
      case 1:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(zoneclock < zoneanidur){
            if(mspassed(zoneanims,5)){
              zoneclock++;
              zoneanims = millis();
            }
          }else{
            state = 2;
            ThePuck.MASTERPUCK = true;
          }
        }else{
          reset();
        }
        break;
      }
      case 2:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(zonebarclock < zonebanidur){
            if(mspassed(zonebanims,5)){
              zonebarclock++;
              zonebanims = millis();
            }
          }else{
            zonebarclock = zonebanidur;
            type = 2;
            state = 3;
          }
          
          if(!ThePuck.noConnections()){
            ThePuck.removeConnections();
          }
        }else{
          reset();
        }
        break;
      }
      case 3:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(ThePuck.x < x-sliderlength/2){
            state = 4;
          }
          circuitRun = false;
        }else{
          reset();
        }
        break;
        
      }
      
      case 4:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(ThePuck.x > x-sliderlength/2){
            state = 3;
          }
          circuitRun = true;
          //RUN THE SIMULATION
        }else{
          reset();
        }
        break;
        
      }
      
      default:
        state = 0;
        break;
    }
  }
  
  boolean puckWithin(float px, float py){
    if(type == 2){
      return pointincircle(px, py, x, y, h) || pointincircle(px, py, x-sliderlength, y, h) || pointinrect(px, py, x-sliderlength/2,y,sliderlength,w);
    }else{
      return super.puckWithin(px,py);
    }
  }
  
  void reset(){
    circuitRun = false;
    ThePuck.MASTERPUCK = false;
    ThePuck = null;
    state = 0;
    type = 1;
  }
  
  void display(color fcolor, boolean fok, color scolor, boolean sok){
    
    if(state == 0){
      if(zonebarclock > 0){
        float anix = map(zonebarclock, 0, zonebanidur, 0, sliderlength);
        float anialph = map(zonebarclock, 0, zonebanidur, 255, 0);
        noStroke();
        fill(fcolor, anialph);
        rectMode(CENTER);
        rect(x-anix/2,y,anix,w+5);
        
        stroke(255);
        strokeWeight(5);
        line(x-anix,y+w/2+2.5,x,y+w/2+2.5);
        line(x-anix,y-w/2-2.5,x,y-w/2-2.5);
        arc(x,y,w+5,w+5,-PI/2,PI/2);
        arc(x-anix,y,w+5,w+5,PI/2,3*PI/2);
      }else{
        if(zoneclock > 0){
          float aniang = map(zoneclock, 0, zoneanidur, 0, 2*PI);
          stroke(255);
          strokeWeight(5);
          noFill();
          arc(x,y,w+5,w+5,-PI/2,-PI/2+aniang);
        }
        super.display(fcolor, fok, scolor, sok);
      }
    }else if(state == 1){
      float aniang = map(zoneclock, 0, zoneanidur, 0, 2*PI);
      stroke(255);
      strokeWeight(5);
      noFill();
      arc(x,y,w+5,w+5,-PI/2,-PI/2+aniang);
      super.display(fcolor, fok, scolor, sok);
    }else if(state == 2){
      float anix = map(zonebarclock, 0, zonebanidur, 0, sliderlength);
      float anialph = map(zonebarclock, 0, zonebanidur, 255, 0);
      noStroke();
      fill(fcolor, anialph);
      rectMode(CENTER);
      rect(x-anix/2,y,anix,w+5);
      
      stroke(255);
      strokeWeight(5);
      line(x-anix,y+w/2+2.5,x,y+w/2+2.5);
      line(x-anix,y-w/2-2.5,x,y-w/2-2.5);
      arc(x,y,w+5,w+5,-PI/2,PI/2);
      arc(x-anix,y,w+5,w+5,PI/2,3*PI/2);
    }else if(state == 3 || state == 4){
      noStroke();
      if(state == 4){
        fill(fcolor);
      }else{
        fill(0);
      }
      rectMode(CENTER);
      rect(x-sliderlength/2,y,sliderlength,w);
      
      stroke(255);
      strokeWeight(1);
      line(x-sliderlength/2, y+w/2, x-sliderlength/2, y-w/2);
      
      strokeWeight(5);
      line(x-sliderlength,y+w/2+2.5,x,y+w/2+2.5);
      line(x-sliderlength,y-w/2-2.5,x,y-w/2-2.5);
      arc(x,y,w+5,w+5,-PI/2,PI/2);
      arc(x-sliderlength,y,w+5,w+5,PI/2,3*PI/2);
    }
    //super.display(fcolor, fok, scolor, sok);
  }
  
  void setPuck(){
    
  }
  
}
