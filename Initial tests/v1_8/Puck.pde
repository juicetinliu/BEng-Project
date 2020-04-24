class Puck{
  boolean MASTERPUCK;
  int id;
  float x, y;
  float size, aurasize, ringthickness;
  float rotation, comrotation, valrotation;
  boolean selected;
  float mouseoffx, mouseoffy;
  int currZone;
  //boolean oncomspace, onvalspace;
  
  Component selectedComponent;
  int selectedvalue, selectedprefix;
  int comno = components.size();
  
  //testingauras
  boolean beginconnection1 = false;
  int connectclock1 = 0, connectms1 = millis();
  boolean beginconnection2 = false;
  int connectclock2 = 0, connectms2 = millis();
  boolean beginconnection3 = false; //three terminal
  int connectclock3 = 0; //three terminal
  //testingauras
    
  Wire[] connectedWires;
  
  String valtext;
  int menuclock = 0, menums = millis(), menualpha;
  boolean menushow;
  
  Puck(int id, float x, float y, float size){
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.aurasize = 20;
    this.ringthickness = 10;

    this.rotation = 0;
    this.comrotation = 0;
    this.valrotation = 0;
    
    
    this.selected = false; 
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.currZone = checkZone();
    
    this.selectedComponent = components.get(0);
    resetComponent();
    
    //change later?
    this.connectedWires = new Wire[3];
    for(int w = 0; w < connectedWires.length; w++){
      connectedWires[w] = null;
    }
  }
  
  void display(){
    if(MASTERPUCK){
      drawDisc();
      noFill();
      stroke(255);
      strokeWeight(2);
      
      float offsetamount = (size - ringthickness)*0.20;
      arc(x,y,offsetamount,offsetamount,-PI/2+PI/5,1.5*PI-PI/5);
      line(x,y,x,y-offsetamount*0.5);
      //line(x-offsetamount, y-offsetamount, x-offsetamount, y+offsetamount);
      //line(x-offsetamount, y+offsetamount, x+offsetamount*1.1, y);
      //line(x+offsetamount*1.1, y, x-offsetamount, y-offsetamount);
      //triangle(x-offsetamount, y-offsetamount, x-offsetamount, y+offsetamount, x+offsetamount, y);
    }else{
      if(currZone == -1){
        drawAura();
      }
      
      drawDisc();
      if(currZone == 1){
        fill(255,100);
        textAlign(CENTER,CENTER);
        text(valtext,x,y+size/4);
        stroke(255,map(menualpha,0,255,255,50));
        strokeWeight(2);
        noFill();
        selectedComponent.drawComponent(x,y,size-15,rotation,2, true);
      }else{
        fill(255,100);
        textAlign(CENTER,CENTER);
        text(valtext,x,y+size/4);
        selectedComponent.drawComponent(x,y,size-15,rotation,2, false);
      }
      drawMenu();
    }
    //fill(255);
    //text(id, x, y);
    //for(int c = 0; c < selectedComponent.terminals; c++){
    //  if(connectedWires[c] != null){
    //     text(connectedWires[c].id,x+c*20,y-20);
    //  }
    //}
  }
  
  void drawDisc(){
    stroke(255);
    strokeWeight(ringthickness);
    
    if(selected){
      fill(50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        fill(128);
      }else{
        if(currZone != -1){
          fill(128,0,0);
        }else{
          fill(0);
        }
      }
    }
    
    ellipse(x, y, size-ringthickness,size-ringthickness);
  }
  
  void drawAura(){
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
    fill(255,menualpha);
    noStroke();
    pushMatrix();
    translate(x,y);
    if(currZone == 0){
      rotate(radians(comrotation));
    }else if(currZone == 1){
      rotate(radians(valrotation));
    }
    triangle(-size*0.1,-size*0.45,size*0.1,-size*0.45,0,-size*0.55);
    popMatrix();
  }
  
  void drawMenu(){
    if(menushow){
      if(menuclock > 90){
        menualpha = int(map(menuclock,100,90,0,255));
      }else if(menuclock < 10){
        menualpha = int(map(menuclock,0,10,0,255));
      }else{
        menualpha = 255;
      }
      if(currZone == 0){
        drawComMenu();
      }else if(currZone == 1){
        if(selectedComponent.valueChange){
          drawValMenu();
        }
      }
    }
  }
  
  void drawComMenu(){
    drawPointers();
    stroke(255,menualpha);
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
        if(selectedComponent.equals(components.get(i))){
          strokeWeight(3);
          components.get(i).drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true);
          strokeWeight(1);
        }else{
          components.get(i).drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,1, true);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize);
      }
      popMatrix();
    }else{
      menushow = false;
    }
  }
  
  void drawValMenu(){
    drawPointers();
    noFill();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      
      strokeWeight(aurasize/2);
      stroke(intCodetoColour(selectedprefix-1,menualpha));
      ellipse(x,y,size+aurasize*1.5,size+aurasize*1.5); //base ring color
      stroke(lerpColor(intCodetoColour(selectedprefix-1,menualpha),intCodetoColour(selectedprefix,menualpha),float(selectedvalue)/1000), menualpha); //val ring color
      arc(x,y,size+aurasize*1.5,size+aurasize*1.5, 0-PI/2, radians(valrotation)-PI/2);
      
      stroke(255,menualpha);
      strokeWeight(1);
      ellipse(x,y,size+aurasize,size+aurasize);
      ellipse(x,y,size+aurasize*2,size+aurasize*2);
      
      pushMatrix();
      translate(x,y);
      rotate(radians(valrotation));
      fill(255, menualpha);
      noStroke();
      ellipse(0,-size/2-aurasize*0.75,aurasize/2,aurasize/2);
      popMatrix();
      
      pushMatrix();
      translate(x,y);
      stroke(255, menualpha);
      strokeWeight(1);
      for(int i = 0; i < 10; i++){
        for(int j = 0; j < 9; j++){
          rotate(radians(3.6));
          line(0,-size/2-aurasize,0,-size/2-aurasize*1.25);
        }
        rotate(radians(3.6));
        line(0,-size/2-aurasize,0,-size/2-aurasize*1.5);
      }
      popMatrix();
      
      fill(255, menualpha);
      textAlign(CENTER,CENTER);
      text(valtext,x,y+size/4);
    }else{
      menushow = false;
    }
  }
  
  void select(){
    selected = true;
    mouseoffx = mouseX - x;
    mouseoffy = mouseY - y;
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
    Component prev = selectedComponent;
    selectedComponent = components.get(min(comno-1,int(map(comrotation,0,360,0,comno))));
    if(!prev.equals(selectedComponent)){
      resetComponent();
    }
  }
  
  boolean selectComValue(int delta){
    if(!selectedComponent.valueChange){ // wire or switch
      return false;
    }else{
      int valhi = selectedComponent.valHi, vallo = selectedComponent.valLo;
      int prehi = selectedComponent.preHi, prelo = selectedComponent.preLo;
      if(delta > 0){
        if(selectedvalue + delta > valhi){
          if(selectedprefix < prehi){
            selectedvalue = selectedvalue + delta - valhi;
            selectedprefix += 1;
          }else{
            selectedvalue = valhi;
          }
        }else{
          selectedvalue += delta;
        }
      }else{
        if(selectedvalue + delta < vallo){
          if(selectedprefix > prelo){
            selectedvalue = selectedvalue + delta + valhi;
            selectedprefix -= 1;
          }else{
            selectedvalue = vallo;
          }
        }else{
          selectedvalue += delta;
        }
      }
      valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
      return true;
    }
  }
  
  void resetComponent(){
    selectedvalue = selectedComponent.dValue;
    selectedprefix = selectedComponent.dPrefix;
    valrotation = int(selectedvalue*0.36);    
    valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
  }
  
  int checkZone(){
    int outz = -1;
    for(Zone thisz:zones){
      if(thisz.puckWithin(x,y)){
        outz = thisz.id;
      }
    }
    return outz;
  }
  
  void run(){
    
    if(selected){
      mouseMove();
    }
    
    if(updated){
      currZone = checkZone();
      if(currZone == 2 && runzone.ThePuck == null){
        runzone.ThePuck = this;
      }else if(currZone == -1){
        menushow = false;
        menuclock = 0;
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
  
  boolean noConnections(){
    for(int w = 0; w < connectedWires.length; w++){
      if(connectedWires[w] != null){
        return false;
      }
    }
    return true;
  }
  
  void removeConnections(){
    for(int w = 0; w < connectedWires.length; w++){
      Wire thiswire = connectedWires[w];
      if(thiswire != null){
        int puckind = thiswire.connectedPucks.indexOf(this);
        thiswire.connectedPucks.remove(this);
        thiswire.sides.remove(puckind);
        thiswire.checkDestroy();
        thiswire.update();
        connectedWires[w] = null;
      }
    }
    println("removed connections from " + id);
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
        if(thispuck.currZone == -1 && thatpuck.currZone == -1){
          if(circleincircle(thispuck.x,thispuck.y,thispuck.size+thispuck.aurasize,thatpuck.x,thatpuck.y,thatpuck.size+thatpuck.aurasize)){
            connectPucks(thispuck, thatpuck);
          }
        }
      }
    }
  }
}
