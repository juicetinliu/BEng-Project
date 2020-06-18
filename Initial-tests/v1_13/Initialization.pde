void addPucksRandom(int num){
  for(int i = 0; i < num; i++){
    pucks.add(new Puck(i, random(puckSize,width - puckSize),random(puckSize, height - puckSize),puckSize, shakeSettings, scrollSettings));
  }
}

void addPucks(int num){
  for(int i = 0; i < num; i++){
    pucks.add(new Puck(i, 0, 0, puckSize, shakeSettings, scrollSettings));
  }
}

void addWires(int num){
  for(int i = 0; i < num; i++){
    wires.add(new Wire(i));
  }
}

void createComponents(){
  components.add(new Component(0, false, "Wire", "", 2, false, 1));
  
  components.add(new Component(1, true, "Resistor", "R", 2, "Ω", 1, 4, 0, 1, 999, 1, true, 1));
  components.add(new Component(2, true, "Capacitor", "C", 2, "F", 0, 0, -4, 1, 999, 1, true, 1));
  components.add(new Component(3, true, "Inductor", "L", 2, "H", 0, 0, -4, 1, 999, 1, true, 1));
  
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
  components.add(new Component(14, true, "Ammeter", "A", 2, false, 1));
  
  components.add(new Component(15, true, "LED - Red", "D", 2, false, 1));
  components.add(new Component(16, true, "LED - Green", "D", 2, false, 1));
  components.add(new Component(17, true, "LED - Blue", "D", 2, false, 1));
  
  components.add(new Component(18, true, "NMOSFET", "M", 3, false, 1));
  components.add(new Component(19, true, "PMOSFET", "M", 3, false, 1));
  
  
  components.add(new Component(20, true, "Current Source", "I", 2, "A", 0, 4, -4, 1, 999, 1, true, 1));
  components.add(new Component(21, true, "Sinusoidal Current Source", "I", 2, "A", 0, 4, -4, 1, 999, 1, true, 1));
  components.get(21).setTime("Hz", 0, 4, -4, 1, 999, 1);
}

void createCategories(){
  categories.add(new ComponentCategory(0, "Passive Components",0));
  //categories.get(0).addComponent(components.get(0));
  categories.get(0).addComponent(components.get(1));
  categories.get(0).addComponent(components.get(2));
  categories.get(0).addComponent(components.get(3));
  
  categories.add(new ComponentCategory(1, "Switch",0));
  categories.get(1).addComponent(components.get(4));
  
  categories.add(new ComponentCategory(2, "Power Sources",0));
  categories.get(2).addComponent(components.get(5));
  categories.get(2).addComponent(components.get(6));
  categories.get(2).addComponent(components.get(7));
  categories.get(2).addComponent(components.get(20));
  //categories.get(2).addComponent(components.get(21));
  
  categories.add(new ComponentCategory(3, "Diodes",0));  
  categories.get(3).addComponent(components.get(9));
  categories.get(3).addComponent(components.get(15));
  categories.get(3).addComponent(components.get(16));
  categories.get(3).addComponent(components.get(17));

  categories.add(new ComponentCategory(4, "Active Components",0));
  categories.get(4).addComponent(components.get(10));
  categories.get(4).addComponent(components.get(11));
  categories.get(4).addComponent(components.get(18));
  categories.get(4).addComponent(components.get(19));
  
  categories.add(new ComponentCategory(5, "Measurement Tools",0));
  categories.get(5).addComponent(components.get(13));
  categories.get(5).addComponent(components.get(14));
  categories.get(5).addComponent(components.get(12));
}

void createZones(){
  //zones.add(new Zone(0, "Component Selection", 0, width/4,height*0.9,width/2,height*0.2, chipIC));
  //zones.add(new Zone(1, "Component Value Change", 0, width*3/4,height*0.9,width/2,height*0.2, knobIC));
  zones.add(new Zone(0, "Component Category Selection", 0, width*7/16,height*0.9,width*3/8,height*0.2, chipIC));
  zones.add(new Zone(1, "Component Value Change", 0, width*7/8,height*0.9,width/4,height*0.2, knobIC));
  zones.add(new Runzone(2, "Start Simulation", 1, width - puckSize*0.7 , puckSize*0.7 ,puckSize*1.1,puckSize*1.1, null));
  zones.add(new Zone(3, "Category Component Change", 0, width/8,height*0.9,width/4,height*0.2, wrenIC));
  zones.add(new Zone(4, "Component Time Change", 0, width*11/16,height*0.9,width/8,height*0.2, timeIC));
  runzone = (Runzone) zones.get(2);
}

void createButtons(){
  buttons.add(new Button("Settings", height*2/80,height*3/80,height*3/80));
  buttons.add(new Button("AddPucks", height*2/80,height*7/80,height*3/80));
  buttons.add(new Button("RemovePucks", height*2/80,height*11/80,height*3/80));
  //buttons.add(new Button("AddGraph", height*2/80,height*15/80,height*3/80));
}

void createSliders(){
  sliders.add(new Slider("Scrollsen", width*0.6, height*0.2, width*0.5, height*2/80));
  sliders.add(new Slider("Shakesen", width*0.6, height*0.3, width*0.5, height*2/80));
  sliders.add(new Slider("DiscSize", width*0.6, height*0.4, width*0.5, height*2/80));
  //sliders.add(new Slider("DiscRotType", width*0.6, height*0.5, width*0.5, height*2/80));
}
