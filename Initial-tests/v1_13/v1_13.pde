ArrayList<Puck> pucks = new ArrayList<Puck>();
ArrayList<Wire> wires = new ArrayList<Wire>();
ArrayList<Graph> graphs = new ArrayList<Graph>();
ArrayList<Component> components = new ArrayList<Component>();
ArrayList<Zone> zones = new ArrayList<Zone>();
ArrayList<ComponentCategory> categories = new ArrayList<ComponentCategory>();

ArrayList<Button> buttons = new ArrayList<Button>();
ArrayList<Slider> sliders = new ArrayList<Slider>();

boolean removemode = false, graphmode = false;
boolean settingsOpen = false;

Runzone runzone;

boolean circuitRun = false;
boolean circuitChecked = false;
boolean updated = true;
boolean showDebug = false;
//int puckSize = 100;
float shakeSettings = 0.5;
float scrollSettings = 0.5;
int puckSize;
float elapsedtime = 0; //Seconds


Icon knobIC = new Icon("knob");
Icon chipIC = new Icon("chip");
Icon wrenIC = new Icon("wrench");
Icon gearIC = new Icon("gear");
Icon timeIC = new Icon("time");

float oscX, oscY, oscRange;

void setup(){
  size(1200,800);
  surface.setTitle("CircuitSim");
  //size(900,600);
  //smooth();
  //pixelDensity(displayDensity());
  puckSize = height/8;
  randomSeed(7);
  buttons.add(new Button("Settings", height*2/80,height*3/80,height*3/80));
  buttons.add(new Button("AddPucks", height*2/80,height*7/80,height*3/80));
  buttons.add(new Button("RemovePucks", height*2/80,height*11/80,height*3/80));
  //buttons.add(new Button("AddGraph", height*2/80,height*15/80,height*3/80));
  createComponents();
  createCategories();
  createZones();
  addPucks(5);
  
  PFont font = loadFont("HelveticaNeue-20.vlw");
  textFont(font);
  textSize(12);
  //textFont(font, 9);
  sliders.add(new Slider("Scrollsen", width*0.6, height*0.2, width*0.5, height*2/80));
  sliders.add(new Slider("Shakesen", width*0.6, height*0.3, width*0.5, height*2/80));
  //sliders.add(new Slider("DiscSize", width*0.6, height*0.4, width*0.5, height*2/80));
  //sliders.add(new Slider("DiscRotType", width*0.6, height*0.5, width*0.5, height*2/80));
  oscX = width*0.13;
  oscY = height*0.67;
  oscRange = 1;
}
void draw(){
  //if(showDebug){
  //  cursor();
  //}else{
  //  noCursor();
  //}
  drawBackground();
  
  fill(255);
  textAlign(LEFT);
  text(frameRate,10,10);
  //text(graphs.size(),50,10);
  text(elapsedtime , width/2, 10);
  
  drawZones();
  for(Button thisbutton:buttons){
    thisbutton.display();
  }
  
  showGraphs();
    
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
  
  if(settingsOpen){
    showSettingsPanel();
    for(Slider thisslider:sliders){
      thisslider.run();
    }
  }
}

void addPucks(int num){
  for(int i = 1; i <= num; i++){
    pucks.add(new Puck(i, random(puckSize,width - puckSize),random(puckSize, height - puckSize),puckSize, shakeSettings, scrollSettings));
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
  components.add(new Component(0, false, "Wire", "", 2, false, 1));
  
  components.add(new Component(1, true, "Resistor", "R", 2, "Ω", 0, 4, -4, 1, 999, 1, true, 1));
  components.add(new Component(2, true, "Capacitor", "C", 2, "F", 0, 4, -4, 1, 999, 1, true, 1));
  components.add(new Component(3, true, "Inductor", "L", 2, "H", 0, 4, -4, 1, 999, 1, true, 1));
  
  components.add(new Component(4, true, "Switch", "S", 2, false, 2));
  
  components.add(new Component(5, true, "DC Voltage Source", "V", 2, "V", 0, 4, -4, 1, 999, 1, true, 1));
  components.add(new Component(6, true, "Sinusoidal Voltage Source", "V", 2, "V", 0, 4, -4, 1, 999, 1, true, 1));
  components.get(6).setTime("Hz", 0, 4, -4, 1, 999, 1);
  components.add(new Component(7, true, "Triangular Wave Voltage Source", "V", 2, "V", 0, 4, -4, 1, 999, 1, true, 1));
  components.get(7).setTime("Hz", 0, 4, -4, 1, 999, 1);  
  components.add(new Component(8, true, "Square Wave Voltage Source", "V", 2, "V", 0, 4, -4, 1, 999, 1, true, 1));
  components.get(8).setTime("Hz", 0, 4, -4, 1, 999, 1);
  
  components.add(new Component(9, true, "Diode", "D", 2, false, 1));
  
  components.add(new Component(10, true, "NPN BJT", "Q", 3, false, 1));
  components.add(new Component(11, true, "PNP BJT", "Q", 3, false, 1));

  components.add(new Component(12, false, "Oscilloscope", "", 2, "V", 0, 4, -4, 1, 999, 1, true, 1));
  //components.get(12).setTime("s", 0, 4, -4, 1, 999, 1);
  
  components.add(new Component(13, false, "Voltmeter", "", 2, false, 1));
  components.add(new Component(14, false, "Ammeter", "", 2, false, 1));
}

void createCategories(){
  categories.add(new ComponentCategory(0, "Passive Components",1));
  categories.get(0).addComponent(components.get(0));
  categories.get(0).addComponent(components.get(1));
  categories.get(0).addComponent(components.get(2));
  categories.get(0).addComponent(components.get(3));
  
  categories.add(new ComponentCategory(1, "Switch",0));
  categories.get(1).addComponent(components.get(4));
  
  categories.add(new ComponentCategory(2, "Power",0));
  categories.get(2).addComponent(components.get(5));
  categories.get(2).addComponent(components.get(6));
  categories.get(2).addComponent(components.get(7));
  categories.get(2).addComponent(components.get(8));
  
  categories.add(new ComponentCategory(3, "Diode",0));  
  categories.get(3).addComponent(components.get(9));
  
  categories.add(new ComponentCategory(4, "Active Components",0));
  categories.get(4).addComponent(components.get(10));
  categories.get(4).addComponent(components.get(11));
  
  categories.add(new ComponentCategory(5, "Measurement Tools",0));
  categories.get(5).addComponent(components.get(13));
  categories.get(5).addComponent(components.get(14));
  categories.get(5).addComponent(components.get(12));
}

void createZones(){
  //zones.add(new Zone(0, "Component Selection", 0, width/4,height*0.9,width/2,height*0.2, chipIC));
  //zones.add(new Zone(1, "Component Value Change", 0, width*3/4,height*0.9,width/2,height*0.2, knobIC));
  zones.add(new Zone(0, "Component Category Selection", 0, width*5/16,height*0.9,width*3/8,height*0.2, chipIC));
  zones.add(new Zone(1, "Component Value Change", 0, width*7/8,height*0.9,width/4,height*0.2, knobIC));
  zones.add(new Runzone(2, "Start Simulation", 1, width - puckSize*0.7 , puckSize*0.7 ,puckSize*1.1,puckSize*1.1, null));
  zones.add(new Zone(3, "Category Component Change", 0, width/16,height*0.9,width/8,height*0.2, wrenIC));
  zones.add(new Zone(4, "Component Time Change", 0, width*5/8,height*0.9,width/4,height*0.2, timeIC));
  runzone = (Runzone) zones.get(2);
}
