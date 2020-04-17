class Wire{
  int id;
  float x, y;
  float handlelength;
  float handlelim = 200;
  
  ArrayList<Puck> connectedPucks = new ArrayList<Puck>();
  IntList sides = new IntList();
  ArrayList<PVector> lines = new ArrayList<PVector>();
  
  //Wire(int id, float x, float y, ArrayList<Puck> connected){
  //  this.id = id;
  //  this.x = x;
  //  this.y = y;
  //  //this.connectedPucks = connected;
  //}
  
  Wire(int id, ArrayList<Puck> connected, IntList sides){
    this.id = id;
    this.connectedPucks = connected;
    this.sides = sides;
  }
  
  Wire(int id){
    this.id = id;
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
    lines.add(new PVector(0,0));
  }
  
  void display(){
    stroke(255);
    strokeWeight(2);
    noFill();
    if(connectedPucks.size() > 2){
      for(int l = 0; l < lines.size(); l += 2){
        PVector thisanch = lines.get(l);
        PVector thiscont = lines.get(l+1);
        //stroke(255);
        bezier(thisanch.x, thisanch.y, thiscont.x, thiscont.y, x, y, x, y);
        //stroke(255,102,0,128);
        //line(thisanch.x, thisanch.y, thiscont.x, thiscont.y);
      }
      noStroke();
      fill(255);
      ellipse(x,y,10,10);
    }else{
      bezier(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
      //stroke(255,102,0,128);
      //line(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y);
      //line(lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
    }
    //fill(255);
    //text(id,x,y-15);
  }
  
  void update(){
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
        
        if(sides.get(p) == 2){
          cont.rotate(PI + radians(thispuck.rotation));
        }else{
          cont.rotate(radians(thispuck.rotation));
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
        if(sides.get(p) == 2){
          cont.rotate(PI + radians(thispuck.rotation));
        }else{
          cont.rotate(radians(thispuck.rotation));
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
