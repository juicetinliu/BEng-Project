class Wire{
  int id;
  float x, y;
  float handlelength;
  
  ArrayList<Puck> connectedPucks = new ArrayList<Puck>();
  IntList sides = new IntList();
  ArrayList<PVector> lines = new ArrayList<PVector>();
  
  Wire(int id, float x, float y, ArrayList<Puck> connected){
    this.id = id;
    this.x = x;
    this.y = y;
    //this.connectedPucks = connected;
  }
  
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
    //for(Puck thispuck:connectedPucks){
    //  line(lines.get(1).x,lines.get(1).y,thispuck.x,thispuck.y);
    //}
    //fill(255);
    //noStroke();
    //ellipse(lines.get(1).x,lines.get(1).y,5,5);
    //text(id,x,y-10);
    //line(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y);
    //line(lines.get(2).x, lines.get(2).y, lines.get(3).x, lines.get(3).y);
    bezier(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(2).x, lines.get(2).y, lines.get(3).x, lines.get(3).y);
  }
  
  void updatexy(){
    if(connectedPucks.size() > 1){
      PVector avg = new PVector(0,0);
      PVector anch1 = new PVector(0,0);
      PVector anch2 = new PVector(0,0);
      PVector cont1 = new PVector(1,0);
      PVector cont2 = new PVector(1,0);
      for(int p = 0; p < connectedPucks.size(); p++){
        Puck thispuck = connectedPucks.get(p);
        avg.add(thispuck.x,thispuck.y);
        if(p == 0){
          anch1.set(thispuck.x,thispuck.y);
          if(sides.get(p) == 2){
            cont1.rotate(PI + radians(thispuck.rotation));
          }else{
            cont1.rotate(radians(thispuck.rotation));
          }
        }else{
          anch2.set(thispuck.x,thispuck.y);
          if(sides.get(p) == 2){
            cont2.rotate(PI + radians(thispuck.rotation));
          }else{
            cont2.rotate(radians(thispuck.rotation));
          }
        }
      }
      avg.div(connectedPucks.size());
      avg.sub(anch1);
      handlelength = avg.mag();
      cont1.setMag(handlelength);
      cont2.setMag(handlelength);
      cont1.add(anch1);
      cont2.add(anch2);
      lines.set(0,anch1);
      lines.set(1,cont1);
      lines.set(2,cont2);
      lines.set(3,anch2);
      //lines.set(1,avg);
      //lines.set(0,new PVector(connectedPucks.get(0).x,connectedPucks.get(0).y));
      //lines.set(2,new PVector(connectedPucks.get(1).x,connectedPucks.get(1).y));
    }
  }
  
  void run(){
    setid();
    if(updated){
      updatexy();
    }
  }
  
  void setid(){
    id = wires.indexOf(this);
  }
  //float 
  
}

void createWire(Puck puckA, int A, Puck puckB, int B){
  Wire thiswire = new Wire(wires.size());
  thiswire.connectedPucks.add(puckA);
  thiswire.connectedPucks.add(puckB);
  thiswire.sides.append(A);
  thiswire.sides.append(B);
  thiswire.updatexy();
  wires.add(thiswire);
}
