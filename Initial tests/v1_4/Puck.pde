class Puck{
  int id;
  float x, y;
  float size, aurasize;
  float rotation, comrotation;
  boolean selected, beginconnection;
  float mouseoffx, mouseoffy;
  boolean onspace;
  
  int selectedcomponent, terminals = 2;
  int comno = 6;
    
  //testingauras
  boolean beginconnection1 = false;
  int connectclock1 = 0, connectms1 = millis();
  boolean beginconnection2 = false;
  int connectclock2 = 0, connectms2 = millis();
  boolean beginconnection3 = false; //three terminal
  int connectclock3 = 0; //three terminal
  Puck bufferpuck1 = null;
  Puck bufferpuck2 = null; 
  Puck bufferpuck3 = null; //three terminal
  //testingauras
    
  Puck[] connectedpucks = new Puck[2];
  
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
    for(int p = 0; p < connectedpucks.length; p++){
      connectedpucks[p] = null;
    }
  }
  
  void display(){
    //fill(255);
    //text(connectedpucks.size(),x,y-40);
    
    for(int p = 0; p < connectedpucks.length; p++){
      if(connectedpucks[p] != null){
        Puck conpuck = connectedpucks[p];
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
    }
    
    if(onspace){
      drawAura2();
    }
    
    drawDisc();
    if(!onspace){
      drawPointers();
    }
    drawComponent(selectedcomponent,x,y,size-15,rotation,2, false);
    drawMenu();
    //fill(255);
    //text(rotation,x+10,y);
    //text(id,x,y);
  }
  
  void drawDisc(){
    stroke(255);
    strokeWeight(10);
    
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
    
    ellipse(x, y, size-10,size-10);
  }
  
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
      if(menuclock > 90){
        stroke(255,map(menuclock,100,90,0,255));
      }else if(menuclock < 10){
        stroke(255,map(menuclock,0,10,0,255));
      }else{
        stroke(255);
      }
      strokeWeight(1);
      noFill();
      if(menuclock > 0){
        menuclock--;
        pushMatrix();
        translate(x,y);
        for(int i = 0; i < comno; i++){
          float frac = 1/float(comno);
          rotate(frac*PI);
          if(selectedcomponent == i){
            drawComponent(i,0,-size/2-aurasize,size/4,frac*PI+PI/2,2, false);
            strokeWeight(1);
          }else{
            drawComponent(i,0,-size/2-aurasize,size/4,frac*PI+PI/2,1, false);
          }
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
    if(!menushow){
      menushow = true;
      menuclock = 100;
    }else{
      menuclock = 90;
    }
  }
  
  void selectComponent(){
    selectedcomponent = int(map(comrotation,0,360,0,comno));
  }
  
  void run(){
    
    if(selected){
      mouseMove();
    }
    fill(255);
    if(connectedpucks[0] != null){
      text("1: " + connectedpucks[0].id,x,y-70);
    }
    if(connectedpucks[1] != null){
      text("2: " + connectedpucks[1].id,x,y-85);
    }
    
    if(updated){
      if(circleinrect(this.x,this.y,this.size,width/2,height*0.9,width,height*0.2)){
        this.onspace = false;
      }else{
        this.onspace = true;
        this.menushow = false;
      }
    }
    
    if(!beginconnection1 && connectclock1 > 0){
      if(connectclock1 > 0){
        connectclock1 -= 5;
      }else{
        connectclock1 = 0;
      }
    }
    if(!beginconnection2 && connectclock2 > 0){
      if(connectclock2 > 0){
        connectclock2 -= 5;
      }else{
        connectclock2 = 0;
      }
    }
  }
  
  int readyConnectTo(Puck otherpuck){
    float angtopuck = atan2(otherpuck.y-y,otherpuck.x-x);
    float rotrad = radians(rotation);
    float combang = limradians(angtopuck - rotrad);
    if(combang > PI/2 && combang < 3*PI/2){
      if(otherpuck != connectedpucks[1]){
        beginconnection2 = true;
        bufferpuck2 = otherpuck;
      }else{
        beginconnection2 = false;
        bufferpuck2 = null;
        return 0;
      }
    }else{
      if(otherpuck != connectedpucks[0]){
        beginconnection1 = true;
        bufferpuck1 = otherpuck;
      }else{
        beginconnection1 = false;
        bufferpuck1 = null;
        return 0;
      }
    }
    
    //if(circleincircle(x,y,size+aurasize,otherpuck.x,otherpuck.y,otherpuck.size+otherpuck.aurasize)){
      if(beginconnection1){
        if(connectclock1 < 100){
          if(mspassed(connectms1,5)){
            connectclock1 += 1;
            connectms1 = millis();
          }
        }else{
          //connectedpucks[0] = bufferpuck1; //create wire connection between bufferpuck1 and this
          //beginconnection1 = false;
          return 1;
        }
      }
      if(beginconnection2){
        if(connectclock2 < 100){
          if(mspassed(connectms2,5)){
            connectclock2 += 1;
            connectms2 = millis();
          }
        }else{
          //connectedpucks[1] = bufferpuck2;
          //beginconnection2 = false;
          return 2;
        }
      }
    //}else{
    //  updated = false;
    //}
    return 0;
  }
  
}

void connectPucks(Puck puckA, Puck puckB){
  int A = puckA.readyConnectTo(puckB);
  int B = puckB.readyConnectTo(puckA);
  println(A + "," + B);
  if(A != 0 && B != 0){
    puckA.connectedpucks[A-1] = puckB;
    puckB.connectedpucks[B-1] = puckA;
    if(A == 1){
      puckA.beginconnection1 = false;
    }else{
      puckA.beginconnection2 = false;
    }
    if(B == 1){
      puckB.beginconnection1 = false;
    }else{
      puckB.beginconnection2 = false;
    }
    //updated = false;
  }else{
    updated = true;
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
          if(circleincircle(thispuck.x,thispuck.y,thispuck.size+thispuck.aurasize,thatpuck.x,thatpuck.y,thatpuck.size+thatpuck.aurasize)){
            connectPucks(thispuck, thatpuck);
          }
        }
      }
    }
  }
}
