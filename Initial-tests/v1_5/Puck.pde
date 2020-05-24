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
  //testingauras
    
  Wire[] connectedWires = new Wire[2];
  
  
  int menuclock = 0, menums = millis();
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
    for(int w = 0; w < connectedWires.length; w++){
      connectedWires[w] = null;
    }
  }
  
  void display(){
    
    if(onspace){
      drawAura2();
    }
    
    drawDisc();
    //if(!onspace){
    //  drawPointers();
    //}
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
  
  void drawPointers(int menuclock){
    //stroke(255);
    //strokeWeight(1);
    //pushMatrix();
    //translate(x,y);
    //rotate(radians(rotation));
    //line(0,-size*0.5,0,-size*0.6);
    //popMatrix();
    
    //stroke(255,0,0);
    //strokeWeight(2);
    if(menuclock > 90){
      fill(255,map(menuclock,100,90,0,255));
    }else if(menuclock < 10){
      fill(255,map(menuclock,0,10,0,255));
    }else{
      fill(255);
    }
    noStroke();
    //fill(255);
    pushMatrix();
    translate(x,y);
    rotate(radians(comrotation));
    //line(0,-size*0.5,0,-size*0.6);
    triangle(-size*0.1,-size*0.45,size*0.1,-size*0.45,0,-size*0.55);
    popMatrix();
  }
  
  void drawMenu(){
    if(menushow){
      drawPointers(menuclock);
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
        if(mspassed(menums,10)){
          menuclock--;
          menums = millis();
        }
        
        pushMatrix();
        translate(x,y);
        for(int i = 0; i < comno; i++){
          float frac = 1/float(comno);
          rotate(frac*PI);
          if(selectedcomponent == i){
            strokeWeight(3);
            drawComponent(i,0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true);
            strokeWeight(1);
          }else{
            drawComponent(i,0,-size/2-aurasize,size/4,frac*PI+PI/2,1, true);
            strokeWeight(1);
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
    
    //fill(255);
    //if(connectedWires[0] != null){
    //  text("1: " + connectedWires[0].id,x,y-70);
    //}
    //if(connectedWires[1] != null){
    //  text("2: " + connectedWires[1].id,x,y-85);
    //}
    
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
  
  int readyConnectTo(Puck otherPuck){
    float angtopuck = atan2(otherPuck.y-y,otherPuck.x-x);
    float rotrad = radians(rotation);
    float combang = limradians(angtopuck - rotrad);
    int sendBack = 0;
    if(combang > PI/2 && combang < 3*PI/2){
      if(connectedWires[1] != null){
        if(connectedWires[1].connectedPucks.contains(otherPuck)){
          beginconnection2 = false;
        }else{
          beginconnection2 = true;
        }
      }else{
        beginconnection2 = true;
      }
    }else{
      if(connectedWires[0] != null){
        if(connectedWires[0].connectedPucks.contains(otherPuck)){
          beginconnection1 = false;
        }else{
          beginconnection1 = true;
        }
      }else{
        beginconnection1 = true;
      }
    }
    
    if(beginconnection1){
      if(connectclock1 < 100){
        if(mspassed(connectms1,5)){
          connectclock1 += 1;
          connectms1 = millis();
        }
      }else{
        sendBack = 1;
      }
    }
    if(beginconnection2){
      if(connectclock2 < 100){
        if(mspassed(connectms2,5)){
          connectclock2 += 1;
          connectms2 = millis();
        }
      }else{
        sendBack = 2;
      }
    }
    return sendBack;
  }
  
}

void connectPucks(Puck puckA, Puck puckB){
  int A = puckA.readyConnectTo(puckB);
  int B = puckB.readyConnectTo(puckA);
  //println(A + "," + B);
  if(A != 0 && B != 0){
    if(puckA.connectedWires[A-1] == null && puckB.connectedWires[B-1] == null){
      createWire(puckA, A, puckB, B);
    }else if(puckA.connectedWires[A-1] == null){
      addToWire(puckA, A, puckB.connectedWires[B-1]);
    }else if(puckB.connectedWires[B-1] == null){
      addToWire(puckB, B, puckA.connectedWires[A-1]);
    }else{
      combineWires(puckA.connectedWires[A-1], puckB.connectedWires[B-1]);
    }
    
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
  }else{
    updated = true;
  }
  //if(puckA.connectedWires[A-1] == null
  //if(puckA.connectedWires[A-1] == puckB.connectedWires[B-1]){ 
  
  //createWire(puckA, A, puckB, B);
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
