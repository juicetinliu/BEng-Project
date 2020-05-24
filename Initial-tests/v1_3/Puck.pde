class Puck{
  int id;
  float x, y;
  float size, aurasize;
  float rotation, comrotation;
  boolean selected, beginconnection;
  int connectclock = 0;
  float mouseoffx, mouseoffy;
  boolean onspace;
  
  int selectedcomponent, terminals = 2;
  int comno = 4;
  
  Puck connectpuck = null;
  
  //testingauras
  boolean beginconnection1 = false;
  int connectclock1 = 0;
  boolean beginconnection2 = false;
  int connectclock2 = 0;
  Puck connectedpuck1 = null;
  Puck connectedpuck2 = null;
  Puck bufferpuck1 = null;
  Puck bufferpuck2 = null;
  //testingauras
  
  ArrayList<Puck> connectedpucks = new ArrayList<Puck>();
  
  int menuclock;
  boolean menushow;
  
  Puck(int id, float x, float y, float size){
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.selected = false; 
    this.beginconnection = false; 
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.aurasize = 20;
    this.onspace = true;
    this.rotation = 0;
    this.comrotation = 0;
    this.selectedcomponent = 0;
  }
  
  void display(){
    //fill(255);
    //text(connectedpucks.size(),x,y-40);
    
    for(Puck conpuck:connectedpucks){
      stroke(255);
      strokeWeight(2);
      float angtopuck = atan2(conpuck.y-y,conpuck.x-x);
      float x1 = x + size/2*cos(angtopuck);
      float y1 = y + size/2*sin(angtopuck);
      float x2 = conpuck.x - conpuck.size/2*cos(angtopuck);
      float y2 = conpuck.y - conpuck.size/2*sin(angtopuck);
      line(x1,y1,x2,y2);
      fill(255);
    }
    
    if(onspace){
      drawAura2();
    }
    
    stroke(255);
    strokeWeight(1);
    
    if(selected){
      fill(50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        fill(128);
      }else{
        if(!onspace){
          fill(128,0,0);
        }else{
          fill(0);
        }
      }
    }
    
    ellipse(x, y, size,size);
    
    drawPointers();
    
    drawcomponent(selectedcomponent,x,y,size,rotation);
    drawMenu();
    //fill(255);
    //text(rotation,x+10,y);
    //text(selectedcomponent,x-10,y);
  }
  
  //void drawaura1(){
  //  fill(255,128);
  //  noStroke();
  //  ellipse(x, y, size + aurasize, size + aurasize);
    
  //  fill(255,map(connectclock,0,100,50,255));
  //  noStroke();
  //  float connectan = map(connectclock,0,100,0,aurasize);
  //  ellipse(x, y, size + connectan, size + connectan);
  //}
  
  void drawAura2(){
    float totsize = size + aurasize;
    float rotrad = radians(rotation);
    
    fill(255,128);
    noStroke();
    ellipse(x, y, totsize, totsize);
    
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(x,y);
    rotate(rotrad);
    line(0, totsize/2, 0, -totsize/2);
    popMatrix();
    
    fill(255,map(connectclock1,0,100,50,255));
    noStroke();
    float connectan1 = map(connectclock1,0,100,0,aurasize);
    arc(x,y,size+connectan1,size+connectan1,-PI/2+rotrad,PI/2+rotrad);
    
    fill(255,map(connectclock2,0,100,50,255));
    noStroke();
    float connectan2 = map(connectclock2,0,100,0,aurasize);
    arc(x,y,size+connectan2,size+connectan2,PI/2+rotrad,3*PI/2+rotrad);
  }
  
  void drawPointers(){
    stroke(255);
    strokeWeight(1);
    line(x+size*0.5*cos(radians(rotation-90)),y+size*0.5*sin(radians(rotation-90)),x+size*0.6*cos(radians(rotation-90)),y+size*0.6*sin(radians(rotation-90)));
    stroke(255,0,0);
    strokeWeight(2);
    line(x+size*0.5*cos(radians(comrotation-90)),y+size*0.5*sin(radians(comrotation-90)),x+size*0.6*cos(radians(comrotation-90)),y+size*0.6*sin(radians(comrotation-90)));
  }
  
  void drawMenu(){
    if(menushow){
      if(menuclock > 0){
        menuclock--;
        pushMatrix();
        translate(x,y);
        for(int i = 0; i < comno; i++){
          float frac = 1/float(comno);
          rotate(frac*PI);
          drawcomponent(i,0,-size/2-aurasize/2,size/2,frac*PI+PI/2);
          rotate(frac*PI);
          line(0,-size/2,0,-size/2-aurasize);
        }
        popMatrix();
      }else{
        menushow = false;
      }
    }
  }
  
  void mouseMove(){
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
    updated = true;
  }
  
  void showMenu(){
    menushow = true;
    menuclock = 100;
  }
  
  void selectComponent(){
    selectedcomponent = int(map(comrotation,0,360,0,comno));
  }
  
  void run(){
    
    if(selected){
      mouseMove();
    }
    fill(255);
    //if(connectedpuck1 != null){
    //  text(connectedpuck1.id,x,y-55);
    //}
    //if(connectedpuck2 != null){
    //  text(connectedpuck2.id,x,y-40);
    //}
    if(!beginconnection1){
      if(connectclock1 > 0){
        connectclock1 -= 5;
      }else{
        connectclock1 = 0;
      }
    }
    if(!beginconnection2){
      if(connectclock2 > 0){
        connectclock2 -= 5;
      }else{
        connectclock2 = 0;
      }
    }
  }
  
  void connectTo(Puck otherpuck){
    float angtopuck = atan2(otherpuck.y-y,otherpuck.x-x);
    float rotrad = radians(rotation);
    float combang = limradians(angtopuck - rotrad);
    if(combang > PI/2 && combang < 3*PI/2){
      beginconnection2 = true;
      //bufferpuck2 = otherpuck;
      connectedpuck2 = otherpuck;
    }else{
      beginconnection1 = true;
      //beginconnection2 = false;
      //bufferpuck1 = otherpuck;
      connectedpuck1 = otherpuck;
    }
    if(circleincircle(x,y,size+aurasize,otherpuck.x,otherpuck.y,otherpuck.size+otherpuck.aurasize)){
      if(beginconnection1){
        if(connectclock1 < 100){
          connectclock1 += 1;
        }else{
          //if(connectedpuck1 != bufferpuck1){
          //  connectedpuck1 = bufferpuck1;
          //  //connectpuck1.connectedpucks.add(this);
          //}
          if(!connectedpucks.contains(connectedpuck1)){
            connectedpucks.add(connectedpuck1);
            connectedpuck1.connectedpucks.add(this);
          }
        }
      }
      if(beginconnection2){
        if(connectclock2 < 100){
          connectclock2 += 1;
        }else{
          //if(connectedpuck2 != bufferpuck2){
          //  connectedpuck2 = bufferpuck2;
          //  //connectpuck2.connectedpucks.add(this);
          //}
          if(!connectedpucks.contains(connectedpuck2)){
            connectedpucks.add(connectedpuck2);
            connectedpuck2.connectedpucks.add(this);
          }
        }
      }
    }else{
      updated = false;
    }
  }
  
}

void checkPuckSpace(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    if(circleinrect(thispuck.x,thispuck.y,thispuck.size,width/2,height*0.9,width,height*0.2)){
      thispuck.onspace = false;
    }else{
      thispuck.onspace = true;
      thispuck.menushow = false;
    }
  }
}

void checkAuras(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    thispuck.beginconnection1 = false;
    thispuck.beginconnection2 = false;
  }
  updated = false;
  
  if(allpucks.size() > 1){
    for(int p1 = 0; p1 < allpucks.size() - 1; p1++){
      for(int p2 = p1 + 1; p2 < allpucks.size(); p2++){
        Puck thispuck = allpucks.get(p1);
        Puck thatpuck = allpucks.get(p2);
        if(thispuck.onspace && thatpuck.onspace){
          if(!thispuck.connectedpucks.contains(thatpuck) || !thatpuck.connectedpucks.contains(thispuck)){
            if(!thispuck.beginconnection && !thatpuck.beginconnection){
              if(circleincircle(thispuck.x,thispuck.y,thispuck.size+thispuck.aurasize,thatpuck.x,thatpuck.y,thatpuck.size+thatpuck.aurasize)){
                thispuck.connectTo(thatpuck);
                thatpuck.connectTo(thispuck);
                updated = true;
              }
            }
          }
        }
      }
    }
  }
}
