ArrayList<Puck> pucks = new ArrayList<Puck>();
ArrayList<Wire> wires = new ArrayList<Wire>();
ArrayList<Component> components = new ArrayList<Component>();
boolean updated = true;

int puckSize = 100;

void setup(){
  size(1200,800);
  //smooth();
  pixelDensity(displayDensity());
  //pucks.add(new Puck(1, width/2,height/2,50));
  //pucks.add(new Puck(2, width/4,height/2,50));
  randomSeed(16);
  createComponents();
  pucks.add(new Puck(1, random(width),random(height),puckSize));
  pucks.add(new Puck(2, random(width),random(height),puckSize));
  pucks.add(new Puck(3, random(width),random(height),puckSize));
  pucks.add(new Puck(4, random(width),random(height),puckSize));
  //pucks.add(new Puck(5, random(width),random(height),puckSize));
  //pucks.add(new Puck(6, random(width),random(height),puckSize));
  //pucks.add(new Puck(7, random(width),random(height),puckSize));
  
  //pucks.add(new puck(3, width*3/4,height/2,50));
  //pucks.add(new puck(4, width/2,height/4,50));
  //pucks.add(new puck(5, width/2,height*3/4,50));
  PFont font = loadFont("HelveticaNeue-20.vlw");
  textFont(font, 12);
}
void draw(){
  background(0);
  
  fill(255);
  textAlign(LEFT);
  text(frameRate,10,10);
  
  drawZones();
  
  //println(updated);
  for(Wire thiswire:wires){
    thiswire.display();
    thiswire.run();
  }
  
  if(updated){
    checkAuras(pucks);
  }
  
  for(Puck thispuck:pucks){
    thispuck.display();
    thispuck.run();
  }
  
  
}

void drawZones(){
  strokeWeight(1);
  stroke(255);
  rectMode(CENTER);
  fill(128,100);
  rect(width/4,height*0.9,width/2,height*0.2); //component selection zone
  
  rect(width*3/4,height*0.9,width/2,height*0.2); //component valuechange zone  
  
  ellipse(width - puckSize*0.7 , puckSize*0.7 ,puckSize*1.1,puckSize*1.1);
}

void createComponents(){
  components.add(new Component(0, "Wire", 2, false));
  components.add(new Component(1, "Resistor", 2, 'Ω', 1, 4, -4, 1, 999, 1, true));
  components.add(new Component(2, "Capacitor", 2, 'F', 0, 4, -4, 1, 999, 1, true));
  components.add(new Component(3, "Switch", 2, false));
  components.add(new Component(4, "Inductor", 2, 'H', 0, 4, -4, 1, 999, 1, true));
  components.add(new Component(5, "VoltageSource", 2, 'V', 0, 4, -4, 1, 999, 1, true));
}
