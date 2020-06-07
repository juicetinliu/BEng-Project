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
float shakeSettings = 0.5;
float scrollSettings = 0.5;
float puckSize;
float elapsedTime = 0; //Seconds


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
  addPucksRandom(5);
  
  PFont font = loadFont("HelveticaNeue-20.vlw");
  textFont(font);
  textSize(12);
  //textFont(font, 9);
  sliders.add(new Slider("Scrollsen", width*0.6, height*0.2, width*0.5, height*2/80));
  sliders.add(new Slider("Shakesen", width*0.6, height*0.3, width*0.5, height*2/80));
  sliders.add(new Slider("DiscSize", width*0.6, height*0.4, width*0.5, height*2/80));
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
  text(elapsedTime , width/2, 10);
  
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

//void savePrefs(){
//  StringList linesout = new StringList();
  
//  linesout.append(str(circlerad));
//  linesout.append(str(checkring));
//  linesout.append(str(houghThresh));
//  linesout.append(str(scalex));
//  linesout.append(str(scaley));
//  linesout.append(str(offx));
//  linesout.append(str(offy));
//  String[] string = new String[1];
  
//  String savepath = "lines.txt";
//  saveStrings(savepath, linesout.array(string));
//}

//void loadPrefs(){
  
//  String[] lines = loadStrings("lines.txt");
//  int linctr = 0;
//  circlerad = int(lines[linctr]);
//  linctr++;
//  checkring = int(lines[linctr]);
//  linctr++;
//  houghThresh = int(lines[linctr]);
//  linctr++;
//  scalex = float(lines[linctr]);
//  linctr++;
//  scaley = float(lines[linctr]);
//  linctr++;
//  offx = int(lines[linctr]);
//  linctr++;
//  offy = int(lines[linctr]);
//}

void savePucks(){
  StringList linesout = new StringList();
  linesout.append(str(pucks.size()));
  linesout.append(str(wires.size()));
  
  for(Puck tp:pucks){
    String tpdata = "";
    
    tpdata += int(tp.MASTERPUCK) + "|";
    tpdata += tp.id + "|";
    tpdata += tp.x + "|" + tp.y + "|";
    tpdata += tp.baserotation + "|" + tp.prebaserotation + "|" + tp.rotation + "|" + tp.catrotation + "|" + tp.valrotation + "|" + tp.timerotation + "|" + tp.staterotation + "|" + tp.comrotation + "|";
    tpdata += tp.currZone + "|";
    
    tpdata += tp.selectedCategory.id + "|";
    tpdata += tp.selectedComponent.id + "|";
    tpdata += tp.selectedvalue + "|" + tp.selectedprefix + "|" + tp.selectedstate + "|" + tp.selectedTvalue + "|" + tp.selectedTprefix + "|";
    
    for(int w = 0; w < tp.connectedWires.length; w++){
      if(tp.connectedWires[w] != null){
        tpdata += tp.connectedWires[w].id + "|";
      }else{
        tpdata += "n|";
      }
    }
    
    tpdata += tp.voltageAcross  + "|";
    
    linesout.append(tpdata);
  }
  
  for(Wire tw:wires){
    String twdata = "";
    twdata += tw.id + "|";
    twdata += tw.connectedPucks.size() + "|";
    for(int p = 0; p < tw.connectedPucks.size(); p++){
      twdata += tw.connectedPucks.get(p).id + "|";
      twdata += tw.sides.get(p) + "|";
    }
    linesout.append(twdata);
  }
  
  String[] string = new String[1];
  
  String savepath = "layout.txt";
  saveStrings(savepath, linesout.array(string));
}

void loadPucks(){
  String[] lines = loadStrings("layout.txt");
  runzone.ThePuck = null;
  pucks.clear();
  wires.clear();
  addPucks(int(lines[0]));
  addWires(int(lines[1]));
  int linectr = 2;
  for(Puck tp:pucks){
    String[] puckdata = split(lines[linectr], "|");
    
    tp.MASTERPUCK = boolean(int(puckdata[0])); 
    tp.id = int(puckdata[1]);
    tp.x = float(puckdata[2]);
    tp.y = float(puckdata[3]);
    tp.baserotation = float(puckdata[4]);
    tp.prebaserotation = float(puckdata[5]);
    tp.rotation = float(puckdata[6]);
    tp.catrotation = float(puckdata[7]);
    tp.valrotation = float(puckdata[8]);
    tp.timerotation = float(puckdata[9]);
    tp.staterotation = float(puckdata[10]);
    tp.comrotation = float(puckdata[11]);
    tp.currZone = int(puckdata[12]);
    tp.selectedCategory = categories.get(int(puckdata[13]));
    tp.selectedComponent = components.get(int(puckdata[14]));
    tp.selectedvalue = int(puckdata[15]);
    tp.selectedprefix = int(puckdata[16]);
    tp.selectedstate = int(puckdata[17]);
    tp.selectedTvalue = int(puckdata[18]);
    tp.selectedTprefix = int(puckdata[19]);
    for(int w = 0; w < tp.connectedWires.length; w++){
      if(!puckdata[20+w].equals("n")){
        tp.connectedWires[w] = wires.get(int(puckdata[20+w]));
      }else{
        tp.connectedWires[w] = null;
      }
    }
    
    tp.voltageAcross = float(puckdata[23]);
    updated = true;
    tp.run();
    tp.updateValtext();
    tp.updateTimetext();
    linectr++;
  }
  
  for(Wire tw:wires){
    String[] wiredata = split(lines[linectr], "|");
    
    tw.id = int(wiredata[0]);
    for(int p = 0; p < int(wiredata[1]); p++){
      tw.connectedPucks.add(pucks.get(int(wiredata[2+p*2])));;
      tw.sides.append(int(wiredata[3+p*2]));
    }
    tw.update();
    linectr++;
  }
  updated = true;
}
