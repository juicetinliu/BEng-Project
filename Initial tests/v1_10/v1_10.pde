ArrayList<Puck> pucks = new ArrayList<Puck>();
ArrayList<Wire> wires = new ArrayList<Wire>();
ArrayList<Component> components = new ArrayList<Component>();
ArrayList<Zone> zones = new ArrayList<Zone>();

ArrayList<Button> buttons = new ArrayList<Button>();
boolean removemode = false;

Runzone runzone;


boolean circuitRun = false;
boolean circuitChecked = false;
boolean updated = true;
boolean showDebug = false;
//int puckSize = 100;
int puckSize;

Icon knobIC = new Icon("knob");
Icon chipIC = new Icon("chip");


void setup(){
  size(1200,800);
  surface.setTitle("CircuitSim");
  //size(900,600);
  //smooth();
  //pixelDensity(displayDensity());
  puckSize = height/8;
  randomSeed(7);
  buttons.add(new Button("AddPucks", height*2/80,height*3/80,height*3/80));
  buttons.add(new Button("RemovePucks", height*2/80,height*7/80,height*3/80));
  createComponents();
  createZones();
  addPucks(5);
  
  PFont font = loadFont("HelveticaNeue-20.vlw");
  textFont(font, 12);
  //textFont(font, 9);
}
void draw(){
  if(circuitRun){
    background(50);
  }else if(removemode){
    background(100,0,0);
  }else{
    background(0);
  }
  
  fill(255);
  textAlign(LEFT);
  text(frameRate,10,10);
  
  drawZones();
  for(Button thisbutton:buttons){
    thisbutton.display();
  }
  
  for(Wire thiswire:wires){
    thiswire.display();
    thiswire.run();
  }
  
  if(updated){
    checkAuras(pucks);
  }
  
  for(Puck thispuck:pucks){
    thispuck.run();
    thispuck.display();
  }
}

void addPucks(int num){
  for(int i = 1; i <= num; i++){
    pucks.add(new Puck(i, random(puckSize,width - puckSize),random(puckSize, height - puckSize),puckSize));
  }
}

void drawZones(){
  for(Zone thisz:zones){
    if(thisz.id == 2){
      runzone.display(color(128),true,color(255),true);
      runzone.run();
    }else{
      if(!circuitRun){
        thisz.display(color(128,100),true,color(128),true);
      }
    }
  }
  
}

void createComponents(){
  components.add(new Component(0, "Wire", "", 2, false, 1, 1));
  components.add(new Component(1, "Resistor", "R", 2, 'Ω', 0, 4, -4, 1, 999, 1, true, 1, 1));
  components.add(new Component(2, "Capacitor", "C", 2, 'F', 0, 4, -4, 1, 999, 1, true, 1, 1));
  components.add(new Component(3, "Switch", "S", 2, false, 2, 1));
  components.add(new Component(4, "Inductor", "L", 2, 'H', 0, 4, -4, 1, 999, 1, true, 1, 1));
  components.add(new Component(5, "Voltage Source", "V", 2, 'V', 0, 4, -4, 1, 999, 1, true, 1, 4));
  components.add(new Component(6, "Diode", "D", 2, false, 1, 1));
  components.add(new Component(7, "BJT", "Q", 3, false, 1, 2));
}

void createZones(){
  //zones.add(new Zone(0, "Component Selection", 0, width/4,height*0.9,width/2,height*0.2, chipIC));
  //zones.add(new Zone(1, "Component Value Change", 0, width*3/4,height*0.9,width/2,height*0.2, knobIC));
  zones.add(new Zone(0, "Component Selection", 0, width/8,height*0.9,width/4,height*0.2, chipIC));
  zones.add(new Zone(1, "Component Value Change", 0, width*7/8,height*0.9,width/4,height*0.2, knobIC));
  zones.add(new Runzone(2, "Start Simulation", 1, width - puckSize*0.7 , puckSize*0.7 ,puckSize*1.1,puckSize*1.1, null));
  runzone = (Runzone) zones.get(2);
}
