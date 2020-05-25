class Puck{
  boolean MASTERPUCK;
  int id;
  float x, y;
  float size, aurasize, ringthickness;
  float baserotation, prebaserotation;
  float rotation, comrotation, valrotation, staterotation, typerotation;
  float scrollmult;
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
  
  float shakedir;
  float shakeAngThresh = PI/2, shakeMagThresh = 10, shakex, shakey; //ADJUST SHAKE SENSITIVITY - ANG/MAG/COUNTER/SAMPPERIOD
  int shakeCounterThresh = 3, shakeCounter = 0, shakems = millis(), shakeDecayPeriod = 1000;
  boolean shakeReset = false;
  
  Graph puckGraph;
  float voltageAcross; //FOR OSCILLOSCOPE AND VOLTMETER
  
  Puck(int id, float x, float y, float size, float shakeSen, float scrollSen){ //size being 100
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
    this.typerotation = 0;
    
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
    this.shakedir = -1;
    setShakeSettings(shakeSen);
    setScrollSettings(scrollSen);
    this.puckGraph = null;
    this.voltageAcross = 0;
  }
  
  //=======================================================
  //==================== DISPLAY STUFF ====================
  //=======================================================
  void display(){
    pushMatrix();
    translate(x,y);
    if(MASTERPUCK){
      drawDisc();
      drawComponent();
    }else{
      drawAura();
      //===== DRAW MENU BACKING =====
      drawMenuBack();
      //===== DRAW THE DISC =====
      drawDisc();
      //===== DRAW THE COMPONENT ON THE DISC =====
      drawComponent();
      //===== DRAW THE MENUS ABOVE THE DISC =====
      drawMenu();
      
      if(showDebug){
        fill(255);
        text("ID: " + id, 0, -75);
        
        if(selectedComponent.id == 7){
          text("IC: " + currents[0], 100, -15);
          text("IB: " + currents[1], 100, 0);
          text("IE: " + currents[2], 100, 15);
        }else{
          text("I: " + currents[0], 100, 0);
        }
        if(selectedComponent.id == 2 || selectedComponent.id == 6){
          text("V: " + voltages[0], 100, -15);
        }
      }
    }
    popMatrix();
    if(puckGraph != null){
      puckGraph.setAnchor(x,y);
    }
  }
  
  void drawDisc(){
    stroke(255);
    strokeWeight(ringthickness);
    
    if(selected){
      //fill(50);
      float mapshake = map(shakeCounter,0,shakeCounterThresh,50,150);
      fill(mapshake,50,50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        if(removemode){
          stroke(128,0,0);
          fill(128,0,0);
        }else if(graphmode){
          stroke(0,0,128);
          fill(0,0,128);
        }else{
          fill(128);
        }
      }else{
        if(currZone != -1){
          fill(50);
        }else{
          fill(0);
        }
      }
    }
    ellipse(0, 0, size-ringthickness,size-ringthickness);
    if(showDebug){
      pushMatrix();
      rotate(radians(baserotation));
      fill(255,0,0);
      noStroke();
      rectMode(CENTER);
      rect(0,(size-ringthickness)/2,ringthickness/2,ringthickness/2);
      popMatrix();
    }
  }
  
  void drawComponent(){
    if(MASTERPUCK){ //ON-OFF ICON
      noFill();
      stroke(255);
      strokeWeight(2);
      
      float offsetamount = (size - ringthickness)*0.20;
      arc(0,0,offsetamount,offsetamount,-PI/2+PI/5,1.5*PI-PI/5);
      line(0,0,0,-offsetamount*0.5);
    }else{
      if(circuitRun){
        fill(255);
        textAlign(CENTER,CENTER);
        if(selectedComponent.id == 8){ //OSCILLOSCOPE
          if(puckGraph != null){
            stroke(puckGraph.graphColor);
          }else{
            stroke(255);
          }
          strokeWeight(3);
          drawOscilloscope(size, rotation);
        }else if(selectedComponent.id == 9){ //VOLTMETER
          text(voltageAcross + "V",0,0);
        }else if(selectedComponent.id == 10){ //AMMETER
          float currentThrough = 0;
          //Wire tw = connectedWires[0];
          //for(int w = 0; w < tw.connectedPucks.size(); w++){
          //  Puck op = tw.connectedPucks.get(0);
          //  if(op.selectedComponent.NGusable){
          //    if(op.selectedComponent.id == 7){
          //      if(tw.sides.get(w) == 1){
          //        currentThrough += op.currents[0];
          //      }else if(tw.sides.get(w) == 2){
          //        currentThrough += op.currents[2];
          //      }else{
          //        currentThrough += op.currents[1];
          //      }
          //    }else{
          //      if(tw.sides.get(w) == 1){
          //        currentThrough += -op.currents[0];
          //      }else{
          //        currentThrough += op.currents[0];
          //      }
          //    }
          //  }
          //}
          text(currentThrough + "A",0,0);
        }else{
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(valtext,0,size/4);
          selectedComponent.drawComponent(0,0,size-15,rotation,2, false, selectedstate, selectedtype);
        }
      }else{
        if(currZone == 1){ 
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(valtext,0,size/4);
          stroke(255,map(menualpha,0,255,255,50));
          strokeWeight(2);
          noFill();
          selectedComponent.drawComponent(0,0,size-15,rotation,2, true, selectedstate, selectedtype);
        }else if(currZone == 3 && selectedComponent.noTypes <= 1){
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(valtext,0,size/4);
          stroke(255,map(menualpha,0,255,255,50));
          strokeWeight(2);
          noFill();
          selectedComponent.drawComponent(0,0,size-15,rotation,2, true, selectedstate, selectedtype);
        }else{
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(valtext,0,size/4);
          selectedComponent.drawComponent(0,0,size-15,rotation,2, false, selectedstate, selectedtype);
        }
      }
    }
  }
  
  void drawAura(){
    if(currZone == -1 && !circuitRun){
      float totsize = size + aurasize;
      float rotrad = radians(rotation);
      fill(255,128);
      noStroke();
      ellipse(0, 0, totsize, totsize);
      pushMatrix();
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
  }
  
  void drawPointers(){
    fill(255,menualpha);
    noStroke();
    pushMatrix();
    if(currZone == 0){
      rotate(radians(comrotation));
    }else if(currZone == 1){
      rotate(radians(valrotation));
    }else if(currZone == 3){
      rotate(radians(typerotation));
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
        ellipse(0,0,menuBackrad,menuBackrad);
      }else if(currZone == 3){
        if(selectedComponent.noTypes > 1){
          fill(menualpha,50);
          noStroke();
          ellipse(0,0,menuBackrad,menuBackrad);
        }
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          fill(menualpha,50);
          noStroke();
          ellipse(0,0,menuBackrad,menuBackrad);
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
        }else{
          hideMenu();
        }
      }else if(currZone == 2){
      }else if(currZone == 3){
        if(selectedComponent.noTypes > 1){
          drawTypeMenu();
        }else{
          hideMenu();
        }
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          drawStateMenu();
        }
      }
    }
  }
  
  void drawTypeMenu(){
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
      int tottypes = selectedComponent.noTypes;
      for(int i = 0; i < tottypes; i++){
        float frac = 1/float(tottypes);
        rotate(frac*PI);
        if(selectedtype == i){
          strokeWeight(3);
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, selectedstate, i);
          strokeWeight(1);
        }else{
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, selectedstate, i);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
      fill(255,menualpha);
      text(selectedComponent.fullTypeName(selectedtype), 0, -size);
    }else{
      menushow = false;
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
      text(selectedComponent.name, 0, -size);
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
      ellipse(0,0,size+aurasize*1.5,size+aurasize*1.5); //base ring color
      stroke(lerpColor(intCodetoColour(selectedprefix-1,menualpha),intCodetoColour(selectedprefix,menualpha),float(selectedvalue)/1000), menualpha); //val ring color
      arc(0,0,size+aurasize*1.5,size+aurasize*1.5, 0-PI/2, radians(valrotation)-PI/2);
      
      stroke(255,menualpha);
      strokeWeight(1);
      ellipse(0,0,size+aurasize,size+aurasize);
      ellipse(0,0,size+aurasize*2,size+aurasize*2);
      
      pushMatrix();
      rotate(radians(valrotation));
      fill(255, menualpha);
      noStroke();
      ellipse(0,-size/2-aurasize*0.75,aurasize/2,aurasize/2);
      popMatrix();
      
      pushMatrix();
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
      text(valtext,0,size/4);
    }else{
      menushow = false;
    }
  }
  
  //===========================================================
  //==================== INTERACTION STUFF ====================  
  //===========================================================

  void select(){
    selected = true;
    mouseoffx = mouseX - x;
    mouseoffy = mouseY - y;
  }
  
  void resetShake(){
    if(!shakeReset){
      shakedir = -1;
      shakeCounter = 0;
      shakems = millis();
      shakeReset = true;
    }
  }
  
  boolean checkShake(){ //IF TOTAL NUMBER OF [changes between consecutive movement angles is greater than a threshhold] WITHIN A TIMEFRAME IS GREATER THAN THRESHOLD -> Shake detected
    shakeReset = false;    
    PVector diffs = new PVector(x - shakex, y - shakey);
    if(diffs.mag() > shakeMagThresh){ //add movevector angle to shakedir whenever puck is moved
      float currshakedir = limradians(diffs.heading());
      if(shakedir != -1){
        if(minangdiff(shakedir,currshakedir) > shakeAngThresh){
          shakeCounter += 1;
          shakems = millis() + shakeDecayPeriod;
        }
      }
      shakedir = currshakedir;
    }else{
      shakedir = -1;
      if(mspassed(shakems,shakeDecayPeriod)){
        resetShake();
      }
    }
    shakex = x;
    shakey = y;
    return shakeCounter >= shakeCounterThresh;
  }
  
  void mouseRotate(float e){
    //baserotation = (e > 0)? baserotation + 10 : baserotation - 10;
    baserotation = baserotation + e*scrollmult;
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
    }else if(currZone == 3){
      typerotation = limdegrees(typerotation + delta);
      selectType();
      showMenu();
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
  }
  
  void showMenu(){
    if(!menushow){
      menushow = true;
      menuclock = 100;
    }else{
      menuclock = 90;
    }
  }
  
  void hideMenu(){
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
    }else{
      menushow = false;
    }
  }
  
  void selectState(){
    selectedstate = min(selectedComponent.noStates-1,int(map(staterotation,0,360,0,selectedComponent.noStates)));
  }
  
  void selectType(){
    selectedtype = min(selectedComponent.noTypes-1,int(map(typerotation,0,360,0,selectedComponent.noTypes)));
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
    selectedtype = selectedComponent.dType;
    for(int e = 0; e < voltages.length; e++){
      voltages[e] = 0;
      currents[e] = 0;
    }
    valrotation = int(selectedvalue*0.36);
    staterotation = 0;
    typerotation = 0;
    valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
    removeGraph();
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
      if(!circuitRun){
        if(checkShake()){
          print("shook");
          resetShake();
          if(!removeConnections()){
            resetComponent();
          }
        }
      }
    }else{
      resetShake();
    }
    
    if(selectedComponent.id == 9 || selectedComponent.id == 8){ //VOLTMETER
      if(connectedWires[0] != null && connectedWires[1] != null){ 
        voltageAcross = connectedWires[0].voltage - connectedWires[1].voltage;
      }
    }
    if(selectedComponent.id == 8){ //OSCILLOSCOPE - ADD GRAPH
      addGraph(new Graph(oscX,oscY,100,100,1,true));
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
  
  //==========================================================
  //==================== CONNECTION STUFF ====================
  //==========================================================

  boolean noConnections(){
    for(int w = 0; w < connectedWires.length; w++){
      if(connectedWires[w] != null){
        return false;
      }
    }
    return true;
  }
  
  boolean removeConnections(){ //return false if nothing is removed
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
      return true;
    }
    return false;
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
  
  boolean addGraph(Graph newgraph){
    if(puckGraph == null){
      puckGraph = newgraph;
      graphs.add(newgraph);
      return true;
    }
    return false;
  }
  
  boolean removeGraph(){
    if(puckGraph != null){
      graphs.remove(puckGraph);
      puckGraph = null;
      return true;
    }
    return false;
  }
  
  void setShakeSettings(float shakeval){ //0 - SHAKE ALOT (UNSENSITIVE); 1 - SHAKE A LITTLE (SENSITIVE)
    shakeAngThresh = map(shakeval,0,1,PI-1,PI/4);
    shakeCounterThresh = int(map(shakeval,0,1,5,3));
    shakeMagThresh = map(shakeval,0,1,10,1);
    shakeDecayPeriod = int(map(shakeval,0,1,500,1500));
  }
  
  void setScrollSettings(float scrollval){ //0 - SCROLL ALOT (UNSENSITIVE); 1 - SCROLL A LITTLE FOR MASSIVE ROTATION (SENSITIVE)
    scrollmult = (scrollval < 0.5) ? map(scrollval, 0, 0.5, 0.01, 1) : map(scrollval, 0.5, 1, 1, 100);
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

void setAllPuckInformationZero(){
  for(Puck tp:pucks){
    for(int e = 0; e < tp.voltages.length; e++){
      tp.voltages[e] = 0;
      tp.currents[e] = 0;
    }
  }
}

void resetAllPuckGraphs(){
  for(Puck tp:pucks){
    if(tp.puckGraph != null){
      tp.puckGraph.resetValues();
    }
  }
}

void updateAllPuckGraphs(int timeelapsed){
  for(Puck tp:pucks){
    if(tp.puckGraph != null){
      if(tp.puckGraph.OSCILLOSCOPE){
        tp.puckGraph.addValue(tp.voltageAcross);
      }else{
        tp.puckGraph.addValue(tp.currents[0]);
      }
    }
  }
}

//void updateAllOscGraphs(int timeelapsed){
//  for(Puck tp:pucks){
//    if(
//    if(tp.puckGraph != null){
//      tp.puckGraph.addValue(tp.currents[0]);
//    }
//  }
//}
