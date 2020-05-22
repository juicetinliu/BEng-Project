class Puck{
  boolean MASTERPUCK;
  int id;
  float x, y;
  float size, aurasize, ringthickness;
  float baserotation, prebaserotation;
  float rotation, comrotation, valrotation, staterotation;
  boolean selected;
  float mouseoffx, mouseoffy;
  int currZone;
  
  Component selectedComponent;
  int selectedvalue, selectedprefix, selectedstate, selectedtype;
  int comno = components.size();
  
  IntList beginconnection = new IntList();
  IntList connectclock = new IntList();
  IntList connectms = new IntList();
    
  Wire[] connectedWires;
  float[] voltages = new float[3]; //ALL: 0 - voltage || BJT: 0 - VBE, 1 - VCE
  float[] currents = new float[3]; //ALL: 0 - current || BJT: 0 - iC, 1 - iB, 2 - iE
  
  String valtext;
  int menuclock = 0, menums = millis(), menualpha;
  boolean menushow;
  
  float[] shakedir = new float[10];
  float shakeAngThresh = PI/2, shakeMagThresh = 10, shakex, shakey; //ADJUST SHAKE SENSITIVITY - ANG/MAG/COUNTER/SAMPPERIOD
  int shakeCounterThresh = 3, shakeCounter = 0, shakems = millis(), shakeSampPeriod = 25;
  boolean shakeReset = false;
  
  Puck(int id, float x, float y, float size){ //size being 100
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.aurasize = size*0.2; //20
    this.ringthickness = size*0.1; //10

    this.baserotation = random(360);
    this.prebaserotation = baserotation;
    
    this.rotation = 0;
    this.comrotation = 0;
    this.valrotation = 0;
    this.staterotation = 0;
    
    
    this.selected = false; 
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.currZone = checkZone();
    
    this.selectedComponent = components.get(0);
    resetComponent();
    
    for(int i = 0; i < 3; i++){
      beginconnection.append(0);
      connectclock.append(0);
      connectms.append(millis());
    }
    //change later?
    this.connectedWires = new Wire[3];
    for(int w = 0; w < connectedWires.length; w++){
      connectedWires[w] = null;
    }
    for(int e = 0; e < voltages.length; e++){
      voltages[e] = 0;
      currents[e] = 0;
    }
    this.shakex = x;
    this.shakey = y;
    for(int s = 0; s < shakedir.length; s++){
      shakedir[s] = -1;
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
    }else{
      if(currZone == -1 && !circuitRun){
        drawAura();
      }
      drawMenuBack();
      drawDisc();
      if(currZone == 1){
        fill(255,100);
        textAlign(CENTER,CENTER);
        text(valtext,x,y+size/4);
        stroke(255,map(menualpha,0,255,255,50));
        strokeWeight(2);
        noFill();
        selectedComponent.drawComponent(x,y,size-15,rotation,2, true, selectedstate, selectedtype);
      }else{
        fill(255,100);
        textAlign(CENTER,CENTER);
        text(valtext,x,y+size/4);
        selectedComponent.drawComponent(x,y,size-15,rotation,2, false, selectedstate, selectedtype);
      }
      drawMenu();
      
      if(showDebug){
        fill(255);
        text("ID: " + id, x, y - 75);
        text("I: " + currents[0], x + 100, y);
        if(selectedComponent.id == 2 || selectedComponent.id == 6){
          text("V: " + voltages[0], x + 100, y-15);
        }
      }
    }
  }
  
  void drawDisc(){
    stroke(255);
    strokeWeight(ringthickness);
    
    if(selected){
      //fill(50);
      float mapshake = map(shakeCounter,0,10,50,255);
      fill(mapshake,50,50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        if(removemode){
          stroke(128,0,0);
          fill(128,0,0);
        }else{
          fill(128);
        }
      }else{
        if(currZone != -1){
          fill(150);
        }else{
          fill(0);
        }
      }
    }
    pushMatrix();
    translate(x,y);
    ellipse(0, 0, size-ringthickness,size-ringthickness);
    if(showDebug){
      rotate(radians(baserotation));
      fill(255,0,0);
      noStroke();
      rectMode(CENTER);
      rect(0,(size-ringthickness)/2,ringthickness/2,ringthickness/2);
    }
    popMatrix();
  }
  
  void drawAura(){
    float totsize = size + aurasize;
    float rotrad = radians(rotation);
    fill(255,128);
    noStroke();
    ellipse(x, y, totsize, totsize);
    pushMatrix();
    translate(x,y);
    rotate(rotrad);
    int terminals = selectedComponent.terminals;
    if(terminals == 3){
      rotate(-2*PI/12);
    }
    for(int i = 0; i < terminals; i++){
      stroke(0);
      strokeWeight(1);
      float connectAng = 2*PI/terminals;
      
      line(0, 0, 0, -totsize/2);
      
      int currclock = connectclock.get(i);
      fill(255,map(currclock,0,100,50,255));
      noStroke();
      float connectRad = map(currclock,0,100,0,aurasize);
      arc(0,0,size+connectRad,size+connectRad,-PI/2,-PI/2+connectAng);
      
      rotate(connectAng);
    }
    popMatrix();
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
    }else if(currZone == -1 && circuitRun){
      rotate(radians(staterotation));
    }
    triangle(-size*0.1,-size*0.45,size*0.1,-size*0.45,0,-size*0.55);
    popMatrix();
  }
  
  void drawMenuBack(){
    if(menushow){
      float menuBackrad = map(menualpha,0,255,size,size+aurasize*4);
      if(currZone == 0){
        fill(menualpha,50);
        noStroke();
        ellipse(x,y,menuBackrad,menuBackrad);
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          fill(menualpha,50);
          noStroke();
          ellipse(x,y,menuBackrad,menuBackrad);
        }
      }
    }
  }
  
  void drawMenu(){
    if(menushow){
      if(currZone == 0){
        drawComMenu();
      }else if(currZone == 1){
        if(selectedComponent.valueChange){
          drawValMenu();
        }
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          drawStateMenu();
        }
      }
    }
  }
  
  void drawStateMenu(){
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
      int totstates = selectedComponent.noStates;
      for(int i = 0; i < totstates; i++){
        float frac = 1/float(totstates);
        rotate(frac*PI);
        if(selectedstate == i){
          strokeWeight(3);
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, i, selectedtype);
          strokeWeight(1);
        }else{
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, i, selectedtype);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
    }else{
      menushow = false;
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
          components.get(i).drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, 0, 0);
          strokeWeight(1);
        }else{
          components.get(i).drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,1, true, 0, 0);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
      fill(255,menualpha);
      text(selectedComponent.name, x, y - size);
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
  
  void resetShake(){
    if(!shakeReset){
      for(int s = 0; s < shakedir.length; s++){
        shakedir[s] = -1;
      }
      shakeCounter = 0;
      shakeReset = true;
    }
  }
  
  void updateShake(){
    shakeReset = false;
    for(int s = shakedir.length - 1; s > 0; s--){ //Push back dirs
      shakedir[s] = shakedir[s-1];
    }    
    PVector diffs = new PVector(x - shakex, y - shakey);
    if(diffs.mag() > shakeMagThresh){ //add movevector angle to shakedir whenever puck is moved
      shakedir[0] = limradians(diffs.heading());
      //print(degrees(shakedir[0]) + " ");
      //print("[" + degrees(shakedir[0]) + "| " + (mouseY - mouseoffy - y) + "," + (mouseX - mouseoffx - x) + "] ");
    }else{
      shakedir[0] = -1;
      //print("!! ");
    }
    shakex = x;
    shakey = y;
  }
  
  boolean checkShake(){ //IF TOTAL NUMBER OF [changes between consecutive movement angles is greater than a threshhold] WITHIN A TIMEFRAME IS GREATER THAN THRESHOLD -> Shake detected
    shakeCounter = 0;
    for(int s = 0; s < shakedir.length-1; s++){
      if(shakedir[s] != -1 && shakedir[s+1] != -1){
        fill(255);
        if(minangdiff(shakedir[s],shakedir[s+1]) > shakeAngThresh){
          shakeCounter += 1;
          fill(255,0,0);
        }
        //print("[" + degrees(minangdiff(shakedir[s],shakedir[s+1])) + "| " + degrees(shakedir[s]) + "," + degrees(shakedir[s+1]) + "] ");
        //text(minangdiff(shakedir[s],shakedir[s+1]),x + s * 50,y + 75);
      }
    }
    return shakeCounter >= shakeCounterThresh;
  }
  
  void mouseRotate(float e){
    //baserotation = (e > 0)? baserotation + 10 : baserotation - 10;
    baserotation = baserotation + e;
    float rotationdelta = baserotation - prebaserotation;
    if(rotationdelta != 0){
      zoneRotate(rotationdelta);
      prebaserotation = baserotation;
    }
  }
  
  void zoneRotate(float delta){
    if(currZone == 0){
      comrotation = limdegrees(comrotation + delta);
      selectComponent();
      showMenu();
    }else if(currZone == 1){
      float mult = pow(10,min(2,int(abs(delta)/4)));
      delta = delta*mult;
      if(selectComValue(int(delta))){
        valrotation = int(selectedvalue*0.36);
      }
      showMenu();
    }else if(currZone == 2){
    }else{
      if(circuitRun){
        staterotation = limdegrees(staterotation + delta);
        selectState();
        showMenu();
      }else{
        rotation = limdegrees(rotation + delta);
      }
    }
  }
  
  void mouseMove(){
    
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
    updated = true;
    if(mspassed(shakems,shakeSampPeriod)){
      shakems = millis();
      updateShake();
      if(checkShake()){
        print("shook");
        resetShake();
        removeConnections();
      }
    }
  }
  
  void showMenu(){
    if(!menushow){
      menushow = true;
      menuclock = 100;
    }else{
      menuclock = 90;
    }
  }
  
  void selectState(){
    selectedstate = min(selectedComponent.noStates-1,int(map(staterotation,0,360,0,selectedComponent.noStates)));
  }
  
  void selectComponent(){
    Component prev = selectedComponent;
    selectedComponent = components.get(min(comno-1,int(map(comrotation,0,360,0,comno))));
    if(!prev.equals(selectedComponent)){
      resetComponent();
      if(prev.terminals != selectedComponent.terminals){
        removeConnections();
      }
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
    selectedstate = selectedComponent.dState;
    for(int e = 0; e < voltages.length; e++){
      voltages[e] = 0;
      currents[e] = 0;
    }
    valrotation = int(selectedvalue*0.36);
    staterotation = 0;
    valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
  }
  
  int checkZone(){
    int outz = -1;
    for(Zone thisz:zones){
      if(thisz.puckWithin(x,y)){
        if(circuitRun){
          if(thisz.id == 2){
            outz = thisz.id;
          }
        }else{
          outz = thisz.id;
        }
      }
    }
    return outz;
  }
  
  void setid(){
    id = pucks.indexOf(this) + 1;
  }
  
  void run(){
    setid();
    
    if(selected){
      mouseMove();
    }else{
      resetShake();
    }
    
    if(menuclock > 90){
      menualpha = int(map(menuclock,100,90,0,255));
    }else if(menuclock < 10){
      menualpha = int(map(menuclock,0,10,0,255));
    }else{
      menualpha = 255;
    }
    
    if(updated){
      currZone = checkZone();
      if(currZone == 2 && runzone.ThePuck == null){
        runzone.ThePuck = this;
      }else if(currZone == -1){
        if(!circuitRun){
          menushow = false;
          menuclock = 0;
        }
      }
    }
    
    for(int i = 0; i < 3; i++){
      if(beginconnection.get(i) == 0 && connectclock.get(i) > 0){
        if(connectclock.get(i) > 0){
          connectclock.sub(i,5);
        }else{
          connectclock.set(i,0);
        }
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
    if(!this.noConnections()){
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
  }
  
  int readyConnectTo(Puck otherPuck){
    float angtopuck = atan2(otherPuck.y-y,otherPuck.x-x);
    float rotrad = radians(rotation);
    float combang = limradians(angtopuck - rotrad);
    int sendBack = 0;
    float offset = -PI/2;
    
    int terminals = selectedComponent.terminals;
    float connectAng = 2*PI/terminals;
    if(terminals == 3){
      offset += -2*PI/12;
    }
    for(int i = 0; i < terminals; i++){
      if(withinradians(combang, limradians(offset + i*connectAng), limradians(offset + (i+1)*connectAng))){
        if(connectedWires[i] != null){
          if(connectedWires[i].connectedPucks.contains(otherPuck)){
            beginconnection.set(i,0);
          }else{
            beginconnection.set(i,1);
          }
        }else{
          beginconnection.set(i,1);
        }
      }
    }
    
    for(int i = 0; i < 3; i++){
      if(beginconnection.get(i) == 1){
        if(connectclock.get(i) < 100){
          if(mspassed(connectms.get(i),5)){
            connectclock.add(i,1);
            connectms.set(i,millis());
          }
        }else{
          sendBack = i+1;
        }
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
    
    puckA.beginconnection.set(A-1,0);
    puckB.beginconnection.set(B-1,0);
  }else{
    updated = true;
  }
}

void checkAuras(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    for(int i = 0; i < 3; i++){
      thispuck.beginconnection.set(i,0);
    }
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

void setPuckInformationZero(){
  for(Puck tp:pucks){
    for(int e = 0; e < tp.voltages.length; e++){
      tp.voltages[e] = 0;
      tp.currents[e] = 0;
    }
  }
}
