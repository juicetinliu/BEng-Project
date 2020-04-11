class Wire{
  int id;
  float x, y;
  
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
  }
  
  void display(){
    stroke(255);
    strokeWeight(2);
    noFill();
    for(Puck thispuck:connectedPucks){
      line(lines.get(0).x,lines.get(0).y,thispuck.x,thispuck.y);
    }
    fill(255);
    noStroke();
    ellipse(lines.get(0).x,lines.get(0).y,5,5);
    //text(id,x,y-10);
  }
  
  void updatexy(){
    if(connectedPucks.size() > 1){
      PVector avg = new PVector(0,0);
      for(Puck thispuck:connectedPucks){
        avg.add(thispuck.x,thispuck.y);
      }
      avg.div(connectedPucks.size());
      lines.set(0,avg);
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
