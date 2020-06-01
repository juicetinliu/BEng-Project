class Wire{
  int id;
  float x, y;
  float handlelength;
  float handlelim = 200;
  float voltage = 0;
  boolean showVoltage = false;
  float currentDensity = 50;
  
  FloatList currentCounter = new FloatList();
  ArrayList<Puck> connectedPucks = new ArrayList<Puck>();
  IntList sides = new IntList();
  ArrayList<PVector> lines = new ArrayList<PVector>();
  
  Wire(int id){
    this.id = id;
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
  }
  
  void updateVoltage(float voltage){
    this.voltage = voltage; 
  }
  
  void showVoltages(){
    showVoltage = true;
  }
  
  void hideVoltages(){
    showVoltage = false;
  }
  
  void display(){
    if(connectedPucks.size() > 2){
      for(int l = 0; l < lines.size(); l += 2){
        PVector thisanch = lines.get(l);
        PVector thiscont = lines.get(l+1);
        if(darkMode){
          stroke(255);
        }else{
          stroke(0);
        }
        strokeWeight(2);
        noFill();
        bezier(thisanch.x, thisanch.y, thiscont.x, thiscont.y, x, y, x, y);
        //stroke(255,102,0,128);
        //line(thisanch.x, thisanch.y, thiscont.x, thiscont.y);
      }
      noStroke();
      if(darkMode){
        fill(255);
      }else{
        fill(0);
      }
      ellipse(x,y,10,10);
      
    }else{
      if(darkMode){
        stroke(255);
      }else{
        stroke(0);
      }
      strokeWeight(2);
      noFill();
      bezier(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
      //stroke(255,102,0,128);
      //line(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y);
      //line(lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
    }
    float tx = x;
    float ty = y;
    if(connectedPucks.size() <= 2){
      tx = bezierPoint(lines.get(0).x, lines.get(1).x, lines.get(3).x, lines.get(2).x, 0.5);
      ty = bezierPoint(lines.get(0).y, lines.get(1).y, lines.get(3).y, lines.get(2).y, 0.5);
    }
    
    //fill(255);
    //
   
    if(showDebug){
      if(darkMode){
        fill(255);
      }else{
        fill(0);
      }
      text("ID: " + id,tx,ty+15);
      text("V: " + voltage,tx,ty-15);
    }
    
    if(circuitRun){
      drawCurrents(tx, ty);
    }
    
    if(id == 0){
      strokeWeight(2);
      if(darkMode){
        stroke(255);
      }else{
        stroke(0);
      }
      line(tx,ty,tx,ty+puckSize*0.2);
      line(tx-puckSize*0.15,ty+puckSize*0.2,tx+puckSize*0.15,ty+puckSize*0.2);
      line(tx-puckSize*0.1,ty+puckSize*0.25,tx+puckSize*0.1,ty+puckSize*0.25);
      line(tx-puckSize*0.05,ty+puckSize*0.30,tx+puckSize*0.05,ty+puckSize*0.30);
    }
  }
  
  void drawCurrents(float x, float y){
    //text(connectedPucks.size(),x+50,y - 10);
    //text(sides.size(),x+50,y);
    //text(lines.size(),x+50,y + 10);
    float current = 0;
    if(connectedPucks.size() > 2){
      for(int l = 0; l < lines.size(); l += 2){
        Puck thispuck = connectedPucks.get(l/2);
        PVector thisanch = lines.get(l);
        PVector thiscont = lines.get(l+1);
        
        if(sides.get(l/2) == 1){
          current = -thispuck.extraInformation[0];
        }else{
          current = thispuck.extraInformation[0];
        }
        moveElectrons(l/2, thisanch.x, thisanch.y, thiscont.x, thiscont.y, x, y, x, y, current, currentDensity);
        //fill(255);
        //text(current,x+50 + l*25,y);
      }
    }else{
      Puck thispuck = connectedPucks.get(0);
      if(sides.get(0) == 1){
        current = -thispuck.extraInformation[0];
      }else{
        current = thispuck.extraInformation[0];
      }
      moveElectrons(0, lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y, current, currentDensity);
      //fill(255);
      //text(current,x+50,y);
    }
  }
  
  void matchCurrentCounters(){
    if(currentCounter.size() == connectedPucks.size()){
      return;
    }else{
      while(currentCounter.size() != connectedPucks.size()){
        if(currentCounter.size() < connectedPucks.size()){
          currentCounter.append(0);
        }else{
          currentCounter.remove(0);
        }
      }
    }
  }
  
  //calculate average point as average of all bezier curves???
  void update(){
    matchCurrentCounters();
    lines.clear();
    if(connectedPucks.size() > 1){
      PVector avg = new PVector(0,0);
      for(Puck thispuck:connectedPucks){
        avg.add(thispuck.x,thispuck.y);
      }
      avg.div(connectedPucks.size());
      PVector lulavg = new PVector(0,0);
      for(int p = 0; p < connectedPucks.size(); p++){
        Puck thispuck = connectedPucks.get(p);
        PVector anch = new PVector(thispuck.x,thispuck.y);
        PVector cont = new PVector(1,0);
        PVector handle = avg.copy();
        
        if(thispuck.selectedComponent.terminals == 3){
          if(sides.get(p) == 3){
            cont.rotate(radians(thispuck.rotation) + PI);
          }else if(sides.get(p) == 2){
            cont.rotate(radians(thispuck.rotation) + PI/3);
          }else{
            cont.rotate(radians(thispuck.rotation) - PI/3);
          }
        }else{
          if(sides.get(p) == 2){
            cont.rotate(PI + radians(thispuck.rotation));
          }else{
            cont.rotate(radians(thispuck.rotation));
          }
        }
        
        handlelength = max(0,handle.sub(anch).mag());
        cont.setMag(handlelength);
        cont.add(anch);
        
        cont.sub(anch).setMag(handlelength);
        lulavg.add(cont);
      }
      lulavg.div(4.3);
      avg.add(lulavg);
      avg = limtoscreen(avg);
      
      x = avg.x;
      y = avg.y;
      
      for(int p = 0; p < connectedPucks.size(); p++){
        Puck thispuck = connectedPucks.get(p);
        PVector anch = new PVector(0,0);
        PVector cont = new PVector(1,0);
        PVector handle = avg.copy();
        anch.set(thispuck.x,thispuck.y);
        
        if(thispuck.selectedComponent.terminals == 3){
          if(sides.get(p) == 3){
            cont.rotate(radians(thispuck.rotation) + PI);
          }else if(sides.get(p) == 2){
            cont.rotate(radians(thispuck.rotation) + PI/3);
          }else{
            cont.rotate(radians(thispuck.rotation) - PI/3);
          }
        }else{
          if(sides.get(p) == 2){
            cont.rotate(PI + radians(thispuck.rotation));
          }else{
            cont.rotate(radians(thispuck.rotation));
          }
        }
        
        handlelength = handle.sub(anch).mag();
        cont.setMag(handlelength);
        cont.add(anch);
        
        lines.add(anch);
        lines.add(limtoscreen(cont)); 
        
        PVector lul = cont.copy();
        lul.sub(anch).setMag(handlelength);
        lulavg.add(lul);
      }
    }
  }
  
  void run(){
    setid();
    if(updated){
      update();
    }
  }
  
  void setid(){
    id = wires.indexOf(this);
  }
  
  void checkDestroy(){
    if(connectedPucks.size() <= 1){
      for(int p = 0; p < connectedPucks.size(); p++){
        Puck thispuck = connectedPucks.get(p);
        thispuck.connectedWires[sides.get(p)-1] = null;
      }
      wires.remove(this);
    }
  }
  
  void moveElectrons(int index, float ax, float ay, float bx, float by, float cx, float cy, float dx, float dy, float current, float density){
    float wireLength = bezierLength(ax,ay,bx,by,cx,cy,dx,dy,0.01);
    int electronNo = max(1,int(wireLength/density));
    //float percentMotion = current * (millis()/1000.0) % 1.0;  // 0 - 1 per SECOND
    currentCounter.set(index, (currentCounter.get(index) + current) % 1000);
    fill(255,255,0);
    noStroke();
    //if(electronPosition > 0){
    if(current > 0){
      for(int i = 0; i < electronNo; i++){
        float percentMoved = float(i)/float(electronNo) + (currentCounter.get(index)/(float(1000*electronNo)));
        //float percentMoved = float(i)/float(electronNo) + (percentMotion/float(electronNo));
        float x = bezierPoint(ax, bx, cx, dx, percentMoved);
        float y = bezierPoint(ay, by, cy, dy, percentMoved);
        ellipse(x,y,10,10);
        //text(electronPosition, x, y-15);
      }
    }else{
      for(int i = 1; i <= electronNo; i++){
        float percentMoved = float(i)/float(electronNo) + (currentCounter.get(index)/(float(1000*electronNo)));
        //float percentMoved = float(i)/float(electronNo) + (percentMotion/float(electronNo));
        float x = bezierPoint(ax, bx, cx, dx, percentMoved);
        float y = bezierPoint(ay, by, cy, dy, percentMoved);
        ellipse(x,y,10,10);
        //text(electronPosition, x, y-15);
      }
    }
  }
}

void addToWire(Puck puckA, int A, Wire thiswire){
  thiswire.connectedPucks.add(puckA);
  thiswire.sides.append(A);
  thiswire.update();
  //wires.add(thiswire);
  puckA.connectedWires[A-1] = thiswire;
  println("added " + puckA.id + ":" + A + " to wire " + thiswire.id);
}

void combineWires(Wire wireA, Wire wireB){
  if(!wireA.connectedPucks.equals(wireB.connectedPucks)){
    wireA.connectedPucks.addAll(wireB.connectedPucks);
    wireA.sides.append(wireB.sides);
    for(int p = 0; p < wireB.connectedPucks.size(); p++){
      Puck thispuck = wireB.connectedPucks.get(p);
      thispuck.connectedWires[wireB.sides.get(p)-1] = wireA;
    }
    wireA.update();
    wires.remove(wireB);
    println("combined wire " + wireA.id + " with wire " + wireB.id);
  }else{
    println("no changes to wire " + wireA.id);    
  }
}

void createWire(Puck puckA, int A, Puck puckB, int B){
  Wire thiswire = new Wire(wires.size());
  thiswire.connectedPucks.add(puckA);
  thiswire.connectedPucks.add(puckB);
  thiswire.sides.append(A);
  thiswire.sides.append(B);
  thiswire.update();
  wires.add(thiswire);
  puckA.connectedWires[A-1] = thiswire;
  puckB.connectedWires[B-1] = thiswire;
  println("created wire " + thiswire.id + " between " + puckA.id + ":" + A + " & " + puckB.id + ":" + B);
}

void setWireVoltagesZero(){
  for(Wire tw:wires){
    tw.voltage = 0;
  }
}
