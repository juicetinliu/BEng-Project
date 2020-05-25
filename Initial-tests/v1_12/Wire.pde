class Wire{
  int id;
  float x, y, size;
  float handlelength;
  float handlelim = 200;
  float voltage = 0;
  boolean showVoltage = false;
  float currentDensity = 50;
  
  FloatList currentCounter = new FloatList();
  ArrayList<Puck> connectedPucks = new ArrayList<Puck>();
  IntList sides = new IntList();
  ArrayList<PVector> lines = new ArrayList<PVector>();
  
  Graph wireGraph;
  
  Wire(int id){
    this.id = id;
    this.size = 10;
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    this.wireGraph = null;
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
        stroke(255);
        strokeWeight(2);
        noFill();
        bezier(thisanch.x, thisanch.y, thiscont.x, thiscont.y, x, y, x, y);
        //stroke(255,102,0,128);
        //line(thisanch.x, thisanch.y, thiscont.x, thiscont.y);
        text(sides.get(l/2),x,y);
      }
      
    }else{
      stroke(255);
      strokeWeight(2);
      noFill();
      bezier(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
      //stroke(255,102,0,128);
      //line(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y);
      //line(lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
    }
    noStroke();
    fill(255);
    if(pointincircle(mouseX,mouseY,x,y,size)){
      ellipse(x,y,size*1.5,size*1.5);
    }else{
      ellipse(x,y,size,size);
    }
    
   
    if(showDebug){
      fill(255);
      text("ID: " + id,x,y+15);
      text("V: " + voltage,x,y-15);
    }
    
    if(circuitRun){
      drawCurrents(x, y);
    }
    
    if(id == 0){
      strokeWeight(2);
      stroke(255);
      line(x,y,x,y+puckSize*0.2);
      line(x-puckSize*0.15,y+puckSize*0.2,x+puckSize*0.15,y+puckSize*0.2);
      line(x-puckSize*0.1,y+puckSize*0.25,x+puckSize*0.1,y+puckSize*0.25);
      line(x-puckSize*0.05,y+puckSize*0.30,x+puckSize*0.05,y+puckSize*0.30);
    }
    
    if(wireGraph != null){
      wireGraph.setAnchor(x,y);
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
        
        if(thispuck.selectedComponent.id == 7){
          if(sides.get(l/2) == 1){
            current = thispuck.currents[0];
          }else if(sides.get(l/2) == 2){
            current = thispuck.currents[2];
          }else{
            current = thispuck.currents[1];
          }
        }else{
          if(sides.get(l/2) == 1){
            current = -thispuck.currents[0];
          }else{
            current = thispuck.currents[0];
          }
        }
        moveElectrons(l/2, thisanch.x, thisanch.y, thiscont.x, thiscont.y, x, y, x, y, current, currentDensity);
      }
    }else{
      Puck thispuck = connectedPucks.get(0);
      if(thispuck.selectedComponent.id == 7){
          if(sides.get(0) == 1){
            current = thispuck.currents[0];
          }else if(sides.get(0) == 2){
            current = thispuck.currents[2];
          }else{
            current = thispuck.currents[1];
          }
        }else{
          if(sides.get(0) == 1){
            current = -thispuck.currents[0];
          }else{
            current = thispuck.currents[0];
          }
        }
      moveElectrons(0, lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y, current, currentDensity);
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
      if(connectedPucks.size() <= 2){
        x = bezierPoint(lines.get(0).x, lines.get(1).x, lines.get(3).x, lines.get(2).x, 0.5);
        y = bezierPoint(lines.get(0).y, lines.get(1).y, lines.get(3).y, lines.get(2).y, 0.5);
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
      if(wireGraph != null){
        graphs.remove(wireGraph);
        wireGraph = null;
      }
      wires.remove(this);
    }
  }
  
  void moveElectrons(int index, float ax, float ay, float bx, float by, float cx, float cy, float dx, float dy, float current, float density){
    float wireLength = bezierLength(ax,ay,bx,by,cx,cy,dx,dy,0.01);
    int electronNo = max(1,int(wireLength/density));
    float newcurramount = currentCounter.get(index) + current;
    newcurramount = (newcurramount < 0) ? newcurramount + 1000 : newcurramount;
    currentCounter.set(index, newcurramount % 1000);
    fill(255,255,0);
    noStroke();
    for(int i = 0; i < electronNo; i++){
      float percentMoved = float(i)/float(electronNo) + (currentCounter.get(index)/(float(1000*electronNo)));
      //float percentMoved = float(i)/float(electronNo) + (percentMotion/float(electronNo));
      float x = bezierPoint(ax, bx, cx, dx, percentMoved);
      float y = bezierPoint(ay, by, cy, dy, percentMoved);
      ellipse(x,y,10,10);
    }
  }
  
  boolean addGraph(Graph newgraph){
    if(wireGraph == null){
      wireGraph = newgraph;
      graphs.add(newgraph);
      return true;
    }
    return false;
  }
  
  boolean removeGraph(){
    if(wireGraph != null){
      graphs.remove(wireGraph);
      wireGraph = null;
      return true;
    }
    return false;
  }
}

void addToWire(Puck puckA, int A, Wire thiswire){
  thiswire.connectedPucks.add(puckA);
  thiswire.sides.append(A);
  thiswire.update();
  if(thiswire.wireGraph != null){
    graphs.remove(thiswire.wireGraph);
    thiswire.wireGraph = null;
  }
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
    if(wireA.wireGraph != null){
      graphs.remove(wireA.wireGraph);
      wireA.wireGraph = null;
    }
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
  if(thiswire.wireGraph != null){
    graphs.remove(thiswire.wireGraph);
    thiswire.wireGraph = null;
  }
  wires.add(thiswire);
  puckA.connectedWires[A-1] = thiswire;
  puckB.connectedWires[B-1] = thiswire;
  println("created wire " + thiswire.id + " between " + puckA.id + ":" + A + " & " + puckB.id + ":" + B);
}

void hideWireVoltages(){
  for(Wire tw:wires){
    tw.hideVoltages();
  }
}

void showWireVoltages(){
  for(Wire tw:wires){
    tw.showVoltages();
  }
}

void setWireVoltagesZero(){
  for(Wire tw:wires){
    tw.voltage = 0;
  }
}

void resetAllWireGraphs(){
  for(Wire tw:wires){
    if(tw.wireGraph != null){
      tw.wireGraph.resetValues();
    }
  }
}

void updateAllWireGraphs(int timeelapsed){
  for(Wire tw:wires){
    if(tw.wireGraph != null){
      tw.wireGraph.addValue(tw.voltage);
    }
  }
  
}
