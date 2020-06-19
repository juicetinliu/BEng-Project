import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class v2 extends PApplet {

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
float shakeSettings = 0.5f;
float scrollSettings = 0.5f;
float puckSize;
float elapsedTime = 0; //Seconds
float circuitSimMultiplier = 1;

//PShader LED;

Icon knobIC = new Icon("knob");
Icon chipIC = new Icon("chip");
Icon wrenIC = new Icon("wrench");
Icon gearIC = new Icon("gear");
Icon timeIC = new Icon("time");

float oscX, oscY, oscRange;

public void setup(){
  
  surface.setTitle("CircuitSim");
  //size(900,600);
  //smooth();
  //pixelDensity(displayDensity());
  puckSize = height/8;
  randomSeed(7);
  createComponents();
  createCategories();
  createZones();
  createButtons();
  createSliders();
  addPucksRandom(5);
  
  PFont font = loadFont("HelveticaNeue-20.vlw");
  textFont(font);
  textSize(12);
  
  //LED = loadShader("Frag.glsl", "Vert.glsl");
  //LED.set("ratio",float(width)/float(height));
  //textFont(font, 9);
  oscX = width*0.13f;
  oscY = height*0.67f;
  oscRange = 1;
}
public void draw(){
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
  textAlign(CENTER);
  text(elapsedTime , width/2, 10);
  text("x"+circuitSimMultiplier,width/2,20);
  
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
  
  for(Puck thispuck:pucks){
    if(circuitRun){
      if(thispuck.selectedComponent.name.equals("LED - Red") || thispuck.selectedComponent.name.equals("LED - Green") || thispuck.selectedComponent.name.equals("LED - Blue")){ //LED
        float brightness = min(100,map(thispuck.currents[0],0,0.03f,0,255));
        noStroke();
        //LED.set("cirxy",thispuck.x/width,1-thispuck.y/height);
        //shader(LED);
        if(thispuck.selectedComponent.name.equals("LED - Red")){
          fill(255,0,0,brightness);
        }else if(thispuck.selectedComponent.name.equals("LED - Green")){
          fill(0,255,0,brightness);
        }else if(thispuck.selectedComponent.name.equals("LED - Blue")){
          fill(0,0,255,brightness);
        }
        ellipse(thispuck.x,thispuck.y,thispuck.size*5,thispuck.size*5);
        //rect(width/2,height/2,width,height);
        //resetShader();
      }
    }
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

public void savePucks(){
  StringList linesout = new StringList();
  linesout.append(str(pucks.size()));
  linesout.append(str(wires.size()));
  
  for(Puck tp:pucks){
    String tpdata = "";
    
    tpdata += PApplet.parseInt(tp.MASTERPUCK) + "|";
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
  
  String savepath = sketchPath() + "/data/layout.txt";
  saveStrings(savepath, linesout.array(string));
}

public void loadPucks(){
  String loadpath = sketchPath() + "/data/layout.txt";
  String[] lines = loadStrings(loadpath);
  runzone.reset();
  pucks.clear();
  wires.clear();
  graphs.clear();
  addPucks(PApplet.parseInt(lines[0]));
  addWires(PApplet.parseInt(lines[1]));
  int linectr = 2;
  for(Puck tp:pucks){
    String[] puckdata = split(lines[linectr], "|");
    
    tp.MASTERPUCK = PApplet.parseBoolean(PApplet.parseInt(puckdata[0])); 
    tp.id = PApplet.parseInt(puckdata[1]);
    tp.x = PApplet.parseFloat(puckdata[2]);
    tp.y = PApplet.parseFloat(puckdata[3]);
    tp.baserotation = PApplet.parseFloat(puckdata[4]);
    tp.prebaserotation = PApplet.parseFloat(puckdata[5]);
    tp.rotation = PApplet.parseFloat(puckdata[6]);
    tp.catrotation = PApplet.parseFloat(puckdata[7]);
    tp.valrotation = PApplet.parseFloat(puckdata[8]);
    tp.timerotation = PApplet.parseFloat(puckdata[9]);
    tp.staterotation = PApplet.parseFloat(puckdata[10]);
    tp.comrotation = PApplet.parseFloat(puckdata[11]);
    tp.currZone = PApplet.parseInt(puckdata[12]);
    tp.selectedCategory = categories.get(PApplet.parseInt(puckdata[13]));
    tp.selectedComponent = components.get(PApplet.parseInt(puckdata[14]));
    tp.selectedvalue = PApplet.parseInt(puckdata[15]);
    tp.selectedprefix = PApplet.parseInt(puckdata[16]);
    tp.selectedstate = PApplet.parseInt(puckdata[17]);
    tp.selectedTvalue = PApplet.parseInt(puckdata[18]);
    tp.selectedTprefix = PApplet.parseInt(puckdata[19]);
    for(int w = 0; w < tp.connectedWires.length; w++){
      if(!puckdata[20+w].equals("n")){
        tp.connectedWires[w] = wires.get(PApplet.parseInt(puckdata[20+w]));
      }else{
        tp.connectedWires[w] = null;
      }
    }
    
    tp.voltageAcross = PApplet.parseFloat(puckdata[23]);
    updated = true;
    tp.run();
    tp.updateValtext();
    tp.updateTimetext();
    linectr++;
  }
  
  for(Wire tw:wires){
    String[] wiredata = split(lines[linectr], "|");
    
    tw.id = PApplet.parseInt(wiredata[0]);
    for(int p = 0; p < PApplet.parseInt(wiredata[1]); p++){
      tw.connectedPucks.add(pucks.get(PApplet.parseInt(wiredata[2+p*2])));;
      tw.sides.append(PApplet.parseInt(wiredata[3+p*2]));
    }
    tw.update();
    linectr++;
  }
  updated = true;
}
//checked -> Disable component/value change; rotation only changes state of component (Switch ON/OFF);
//create copy of pucks (once puck is visited, remove from pucks)
//no voltage source -> error
//wire -> merge both sides
//switch -> OFF:ignore component; ON:merge nodes on both sides (act as wire)
//components with one/two null connections -> ignore

//0, "Wire"
//1, "Resistor"
//2, "Capacitor"
//3, "Switch"
//4, "Inductor"
//5, "VoltageSource"
//6, "Diode"
//7, "BJT"

public boolean checkCircuit(){
  boolean hasError = true;
  for(int p = 0; p < pucks.size(); p++){
    Puck checkpuck = pucks.get(p);
    if(!checkpuck.MASTERPUCK){
      Component thiscomp = checkpuck.selectedComponent;
      for(int ck = 0; ck < thiscomp.terminals; ck++){ 
        if(checkpuck.connectedWires[ck] == null){ //all pucks must have connections to nodes
          checkpuck.addError(ck);
          hasError = false;
        }
      }
      if(thiscomp.name.equals("Wire")){ //no pucks can be wires
        checkpuck.addError(404);
        hasError = false;
      }
    }   
  }
  return hasError;
}

public void NGCircuitRT(float RTStepSize, boolean firstiteration){
  StringList lines = new StringList();
  
  lines.append("HEHE"); //TITLE
  
  String icline = ".ic";
  for(int w = 1; w < wires.size(); w++){
    Wire tw = wires.get(w);
    icline += " v(" + tw.id + ")=" + tw.voltage;
  }
  lines.append(icline); //.ic v(1)=.......
  
  for(Puck chkpuck:pucks){
    if(!chkpuck.MASTERPUCK){
      String thisline = "";
      
      Component thiscomp = chkpuck.selectedComponent;
      ComponentCategory thiscat = chkpuck.selectedCategory;
      String IDcode = thiscomp.NGname + chkpuck.id; //NAME AND ID
      
      if(thiscomp.name.equals("Switch")){ //switch
        thisline += IDcode + " ";
        thisline += chkpuck.connectedWires[0].id + " "; //ADD FIRST NODE
        String currNode = chkpuck.connectedWires[1].id + IDcode; //CREATE SECOND NODE FOR CURRENT MEASURE
        thisline += currNode + " "; //ADD SECOND NODE
        
        //===== SWITCH VOLTAGE SOURCE =====
        int swvplus = wires.size() + chkpuck.id; //CREATE SWITCH ON/OFF SOURCE
        String swvline = "";
        swvline += "VST" + chkpuck.id + " " + swvplus + " 0 "; //CREATE SWITCH ON/OFF SOURCE + THRESHOLD VOLTAGE
        
        thisline += swvplus + " 0 switch1 "; //SET SWITCH ON/OFF SOURCE VOLTAGE
        if(chkpuck.selectedstate == 0){
          thisline += "OFF";
          swvline += "0";
        }else{
          thisline += "ON";
          swvline += "2";
        }
        
        //===== ADD CURRENT SENSING SOURCE =====
        String nxtline = "";    //CREATE NEW LINE
        nxtline += "V" + IDcode + " "; //VOLTAGE SOURCE
        nxtline += currNode + " " + chkpuck.connectedWires[1].id + " 0"; //0V VOLTAGE SOURCE IN SERIES TO MEASURE CURRENT
        
        
        lines.append(thisline);
        lines.append(swvline);
        lines.append(nxtline);
      }else if(thiscomp.name.equals("Ammeter")){ //AMMETER --> MAKE IT A VOLTAGE SOURCE 0V
        thisline += "V" + IDcode + " ";
        thisline += chkpuck.connectedWires[0].id + " " + chkpuck.connectedWires[1].id + " 0"; //ADD NODES
        lines.append(thisline);
      }else if(thiscomp.NGusable){
        if(thiscomp.terminals == 2){ //FOR TWO TERMINAL COMPONENTS
          String val = chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix); //VALUE OF PUCK COMPONENT
          String timeval = chkpuck.selectedTvalue + intCodetoNGCode(chkpuck.selectedTprefix);
          thisline += IDcode + " "; //ADD NAME AND ID
          
          //===== ADD NODES =====
          if(thiscat.name.equals("Diodes")){ //DIODES
            String newline = "R" + IDcode + " ";
            newline += chkpuck.connectedWires[0].id + " " + chkpuck.connectedWires[0].id + "D" + IDcode + " 1"; //ADD SMALL RESISTOR IN SERIES WITH DIODE
            lines.append(newline);
            
            thisline += chkpuck.connectedWires[0].id + "D" + IDcode + " ";
          }else{
            thisline += chkpuck.connectedWires[0].id + " "; //ADD FIRST NODE
          }
          
          String currNode = "";
          if(thiscat.name.equals("Power Sources")){ //VOLTAGE SOURCES DON'T NEED EXTRA CURRENT MEASURE
            thisline += chkpuck.connectedWires[1].id + " "; //ADD SECOND NODE
          }else{
            currNode = chkpuck.connectedWires[1].id + IDcode; //CREATE SECOND NODE FOR CURRENT MEASURE
            thisline += currNode + " "; //ADD SECOND NODE
          }
          
          //===== ADD INFORMATION =====
          if(thiscat.name.equals("Power Sources")){ //VOLTAGE SOURCES
            if(thiscomp.name.equals("Sinusoidal Voltage Source") || thiscomp.name.equals("Sinusoidal Current Source")){ //PERIODIC SOURCE SIN(0 1 hZ -time 0)
              thisline += "SIN(0 " + val + " " + timeval + " -";
              thisline += elapsedTime + "s 0)";
            }else if(thiscomp.name.equals("Triangular Wave Voltage Source")){ //PERIODIC SOURCE PWL(T1 V1 <T2 V2 T3 V3 T4 V4 ...>) <r=value> <td=value>    
              float newtvalue = 4*PApplet.parseFloat(chkpuck.selectedTvalue);
              String onetimeval = 1/(newtvalue) + intCodetoNGCode(-chkpuck.selectedTprefix);    //(selectedTValue is frequency), 1/selectedTValue   , invert selectedTprefix
              //String twotimeval = chkpuck.selectedTvalue/2 + intCodetoNGCode(chkpuck.selectedTprefix);
              String thrtimeval = 3/(newtvalue) + intCodetoNGCode(-chkpuck.selectedTprefix);
              thisline += "PWL(0 0 " + onetimeval + " " + val + " ";
              thisline += thrtimeval + " -" + val + " " + timeval + " 0)";
              thisline += " r=0 td=-" + elapsedTime;
            }else{ //DC SOURCE
              if(firstiteration){
                thisline += "PULSE(0 " + val;
              }else{
                thisline += "PULSE(" + val + " " + val;
              }
              thisline += " 0s 1fs 1fs)"; //ADD VALUE OF VOLTAGE SOURCE
            }
          }else{
            if(thiscomp.name.equals("Diode")){ //ADD DIODE MODEL
              thisline += "diode1";
            }else if(thiscomp.name.equals("LED - Red") || thiscomp.name.equals("LED - Green") || thiscomp.name.equals("LED - Blue")){ //ADD LED MODEL
              thisline += "led";
            }else{
              thisline += val; //ADD VALUE OF COMPONENT
            }
            
            if(thiscomp.name.equals("Inductor")){ //INDUCTOR
              thisline += " ic=" + chkpuck.currents[0]; //ADD INITIAL CURRENT
            }else if(thiscomp.name.equals("Capacitor")){ //CAPACITOR
              thisline += " ic=" + chkpuck.voltages[0]; //ADD INITIAL VOLTAGE
            }else if(thiscomp.name.equals("Diode") || thiscomp.name.equals("LED - Red") || thiscomp.name.equals("LED - Green") || thiscomp.name.equals("LED - Blue")){ //DIODE
              thisline += " ic=" + chkpuck.voltages[0]; //ADD INITIAL VOLTAGE
            }
          }
          
          //===== ADD CURRENT SENSING SOURCE =====
          if(!thiscat.name.equals("Power Sources")){ //VOLTAGE SOURCES DON'T NEED EXTRA CURRENT MEASURE
            String nxtline = "";    //CREATE NEW LINE
            nxtline += "V" + IDcode + " "; //CURRENT MEASURE VOLTAGE SOURCE
            nxtline += currNode + " " + chkpuck.connectedWires[1].id + " 0"; //0V VOLTAGE SOURCE IN SERIES TO MEASURE CURRENT
            lines.append(nxtline);
          }
          lines.append(thisline);
          
        }else if(thiscomp.terminals == 3){ //FOR THREE TERMINAL COMPONENTS
          if(thiscat.name.equals("Active Components")){ //BJT or MOSFET
            thisline += IDcode + " "; //ADD NAME AND ID
          
            //===== ADD NODES =====
            String upI = chkpuck.connectedWires[0].id + IDcode; //CREATING CURRENT
            String sideI = chkpuck.connectedWires[2].id + IDcode; //SENSING
            String downI = chkpuck.connectedWires[1].id + IDcode; //NODES
            
            thisline += upI + " "; //ADD COLLECTOR/DRAIN NODE
            thisline += sideI + " "; //ADD BASE/GATE NODE
            thisline += downI + " "; //ADD EMITTER/SOURCE NODE
            
            if(thiscomp.name.endsWith("MOSFET")){
              thisline += downI + " "; //ADD BODY = SOURCE NODE
            }
            
            if(thiscomp.name.equals("NPN BJT")){
              thisline += "QMODN"; //ADD NPN BJT MODEL
            }else if(thiscomp.name.equals("PNP BJT")){
              thisline += "QMODP"; //ADD PNP BJT MODEL
            }else if(thiscomp.name.equals("NMOSFET")){
              thisline += "MOSN"; //ADD NMOSFET MODEL
            }else if(thiscomp.name.equals("PMOSFET")){
              thisline += "MOSP"; //ADD PMOSFET MODEL
            }
            
            if(thiscomp.name.endsWith("BJT")){
              thisline += " ic=" + chkpuck.voltages[0] + ", " + chkpuck.voltages[1]; //ADD INITIAL VOLTAGES (VBE, VCE)
            }else{
              thisline += " ic=" + chkpuck.voltages[0] + ", " + chkpuck.voltages[1] + ", " + chkpuck.voltages[2]; //ADD INITIAL VOLTAGES (VDS, VGS, VBS)              
            }
            String upVs = "V" + IDcode;
            String sideVs = "V" + IDcode;
            String downVs = "V" + IDcode;
            if(thiscomp.name.endsWith("BJT")){
              upVs += "C ";
              sideVs += "B ";
              downVs += "E ";
            }else{
              upVs += "D ";
              sideVs += "G ";
              downVs += "S ";
            }
            upVs += upI + " " + chkpuck.connectedWires[0].id + " 0";
            sideVs += sideI + " " + chkpuck.connectedWires[2].id + " 0";
            downVs += downI + " " + chkpuck.connectedWires[1].id + " 0";
              
            lines.append(thisline);
            lines.append(upVs);
            lines.append(sideVs);
            lines.append(downVs);
          }
          
        }
      }
    }
  }
  
  
  lines.append(".model switch1 sw vt=1");
  lines.append(".model diode1 D");
  lines.append(".model led D(is=1e-22 rs=6 n=1.5 cjo=50p xti=100)");
  lines.append(".model QMODN NPN level=1");
  lines.append(".model QMODP PNP level=1");
  lines.append(".model MOSN NMOS level=1");
  lines.append(".model MOSP PMOS level=1");
  
  //lines.append(".MODEL diode1 D(IS=4.352E-9 N=1.906 BV=110 IBV=0.0001 RS=0.6458 CJO=7.048E-13 VJ=0.869 M=0.03 FC=0.5 TT=3.48E-9 ");
  //lines.append(".option rshunt = 1.0e12");
  //lines.append(".option rseries = 1.0e-4");
  
  lines.append(".control");
  
  String tranline = "tran ";
  
  tranline += RTStepSize/10 + "s ";
  tranline += RTStepSize + "s uic";
  lines.append(tranline);
  
  lines.append("let k = length(time) - 1");
  
  String printline = "print time[k]";
  
  //===== PRINT CURRENTS =====
  for(Puck chkpuck:pucks){
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      ComponentCategory thiscat = chkpuck.selectedCategory;
      if(thiscomp.NGusable){
        if(thiscat.name.equals("Power Sources")){
          if(thiscomp.name.endsWith("Current Source")){
            //printline += " i(I" + chkpuck.id + ")[k]";
          }else{
            printline += " i(V" + chkpuck.id + ")[k]";
          }
        }else if(thiscat.name.equals("Active Components")){
          String idcode = thiscomp.NGname + chkpuck.id;
          if(thiscomp.name.endsWith("BJT")){
              printline += " i(V" + idcode + "C)[k]";
              printline += " i(V" + idcode + "B)[k]";
              printline += " i(V" + idcode + "E)[k]";
            }else{
              printline += " i(V" + idcode + "D)[k]";
              printline += " i(V" + idcode + "G)[k]";
              printline += " i(V" + idcode + "S)[k]";
            }
        }else{
          printline += " i(V" + thiscomp.NGname + chkpuck.id + ")[k]";
        }
      }
    }
  }
  
  //===== PRINT VOLTAGES =====
  for(int w = 1; w < wires.size(); w++){
    Wire tw = wires.get(w);
    printline += " v(" + tw.id + ")[k]";
  }
    
  lines.append(printline);
  
  lines.append(".endc");
  lines.append(".end");
  
  String[] string = new String[1];
  
  String savepath = "data/lines.txt";
  saveStrings(savepath, lines.array(string));
  
  String thepath = sketchPath() + "/" + savepath;
  
  StringList output = new StringList();
  StringList errors = new StringList();
  exec(output, errors, "/usr/local/bin/ngspice", thepath);
  
  for(int o = 0; o < output.size(); o++){
    String line = output.get(o);
    print(o + ": ");
    println(line);
  }
  
  for(String line: errors){
    print("ERR: ");
    println(line);
  }
  
  NGparseOutputRT(output);
}

public void NGparseOutputRT(StringList output){
  int outlen = output.size();
  
  for(int o = outlen - wires.size() + 1; o < outlen; o++){ //FIRST PARSE NODAL VOLTAGES
    String line = output.get(o);
    String[] list = split(line, " = ");
    wires.get(o + wires.size() - outlen).updateVoltage(PApplet.parseFloat(list[1].trim()));
  }
  
  int lineptr = outlen - wires.size();
  for(int p = pucks.size() - 1; p >= 0; p--){ //THEN PARSE COMPONENT INFORMATION AND CURRENTS
    Puck thispuck = pucks.get(p);
    if(!thispuck.MASTERPUCK){
      Component thiscomp = thispuck.selectedComponent;
      ComponentCategory thiscat = thispuck.selectedCategory;
      if(thiscomp.NGusable){
        if(thiscat.name.equals("Active Components")){
          String line = output.get(lineptr);
          String[] list = split(line, " = ");
          thispuck.currents[2] = PApplet.parseFloat(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[1] = PApplet.parseFloat(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[0] = PApplet.parseFloat(list[1].trim());
          lineptr--;
        }else if(thiscomp.name.equals("Current Source")){
          thispuck.currents[0] = thispuck.selectedvalue * pow(1000, thispuck.selectedprefix);
        }else{
          String line = output.get(lineptr);
          String[] list = split(line, " = ");
          thispuck.currents[0] = PApplet.parseFloat(list[1].trim());
          lineptr--;
          if(thiscomp.name.equals("Capacitor")){ //CAPACITOR VOLTAGE
            thispuck.voltages[0] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
          }else if(thiscomp.name.equals("Diode") || thiscomp.name.equals("LED - Red") || thiscomp.name.equals("LED - Green") || thiscomp.name.equals("LED - Blue")){ //DIODE VOLTAGE
            thispuck.voltages[0] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
            //lineptr--;
          }
        }
      } 
    }
  }
  //String line = output.get(lineptr);
  //String[] list = split(line, " = ");
  //return float(list[1].trim());
}
public boolean pointincircle(float x, float y, float cx, float cy, float cr){
  if(dist(x,y,cx,cy) > cr/2){
    return false;
  }else{
    return true;
  }
}

public boolean pointinrect(float x, float y, float rx, float ry, float rw, float rh){
  if(x < rx+rw/2 && x > rx-rw/2 && y < ry+rh/2 && y > ry-rh/2){
    return true;
  }else{
    return false;
  }
}

public boolean circleincircle(float cx, float cy, float cr, float ox, float oy, float or){
  if(dist(cx,cy,ox,oy) > (cr + or)/2){
    return false;
  }else{
    return true;
  }
}

public boolean circleinrect(float cx, float cy, float cr, float rx, float ry, float rw, float rh){
  float testX = cx;
  float testY = cy;

  // which edge is closest?
  if (cx < rx-rw/2){
    testX = rx-rw/2;            // test left edge
  }else if (cx > rx+rw/2){
    testX = rx+rw/2;   // right edge
  }
  if (cy < ry-rh/2){
    testY = ry-rh/2;            // top edge
  }else if (cy > ry+rh/2){
    testY = ry+rh/2;   // bottom edge
  }
  // get distance from closest edges
  float distX = cx-testX;
  float distY = cy-testY;
  float distance = sqrt((distX*distX) + (distY*distY));

  // if the distance is less than the radius, collision!
  if (distance <= cr/2) {
    return true;
  }
  return false;
}
class ComponentCategory{ //CATEGORY
  int id;
  String name;
  ArrayList<Component> cat = new ArrayList<Component>();
  int repCompID;
  
  ComponentCategory(int id, String name, int representative){
    this.id = id;
    this.name = name;
    this.repCompID = representative;
  }
  
  public void drawCategory(float x, float y, float size, float rotation, int strokeweight, boolean customcolour, int state){
    cat.get(repCompID).drawComponent(x, y, size, rotation, strokeweight, customcolour, state);
  }
  
  public void addComponent(Component newComp){
    cat.add(newComp);
  }
  
  public int indComponent(Component thiscomp){
    return cat.indexOf(thiscomp);
  }
}

class Component{
  int id;
  boolean NGusable;
  String name, NGname;
  boolean valueChange;
  String unit;
  int dPrefix, preHi, preLo;
  int dValue, valHi, valLo;
  int dState, noStates;
  int terminals;
  
  boolean timeChange = false;
  String tunit;
  int dTPrefix, TpreHi, TpreLo;
  int dTValue, TvalHi, TvalLo;
  
  
  Component(int id, boolean NGusable, String name, String NGname, int terminals, String unit, int dPrefix, int preHi, int preLo, int dValue, int valHi, int valLo, boolean valueChange, int noStates){
    this.id = id;
    this.NGusable = NGusable;
    this.name = name;
    this.NGname = NGname;
    this.unit = unit;
    this.dPrefix = dPrefix;
    this.dValue = dValue;
    this.valueChange = valueChange;
    this.preHi = preHi;
    this.preLo = preLo;
    this.valHi = valHi; 
    this.valLo = valLo;
    this.terminals = terminals;
    this.noStates = noStates;
    this.dState = 0;
  }
  
  Component(int id, boolean NGusable, String name, String NGname, int terminals, boolean valueChange, int noStates){
    this.id = id;
    this.NGusable = NGusable;
    this.name = name;
    this.NGname = NGname;
    this.valueChange = valueChange;
    this.unit = "";
    this.dPrefix = 0;
    this.dValue = 0;
    this.terminals = terminals;
    this.noStates = noStates;
    this.dState = 0;
  }
  
  public void setTime(String tunit, int dTPrefix, int TpreHi, int TpreLo, int dTValue, int TvalHi, int TvalLo){
    this.tunit = tunit;
    this.dTPrefix = dTPrefix;
    this.dTValue = dTValue;
    this.timeChange = true;
    this.TpreHi = TpreHi;
    this.TpreLo = TpreLo;
    this.TvalHi = TvalHi; 
    this.TvalLo = TvalLo;
  }
  
  public void drawComponent(float x, float y, float size, float rotation, int strokeweight, boolean customcolour, int state){
    rectMode(CENTER);
    pushMatrix();
    translate(x,y);
    rotate(radians(rotation));
    if(!customcolour){
      stroke(255);
      strokeWeight(strokeweight);
      noFill();
    }
    switch(id){
      case 0: //default: wire
        line(-size/2,0,size/2,0);
      break;
      
      case 1: //resistor
        rect(0,0,size*0.8f,size*0.2f);
        line(-size/2,0,-size*0.4f,0);
        line(size/2,0,size*0.4f,0);
      break;
      
      case 2: //capacitor
        line(-size*0.1f,size*0.25f,-size*0.1f,-size*0.25f);
        line(size*0.1f,size*0.25f,size*0.1f,-size*0.25f);
        line(-size/2,0,-size*0.1f,0);
        line(size/2,0,size*0.1f,0);
      break;
      
      case 3: //inductor
        line(-size/2,0,-size*0.4f,0);
        line(size/2,0,size*0.4f,0);
        arc(size*0.3f,0,size*0.2f,size*0.2f,PI,2*PI);
        arc(size*0.1f,0,size*0.2f,size*0.2f,PI,2*PI);
        arc(-size*0.1f,0,size*0.2f,size*0.2f,PI,2*PI);
        arc(-size*0.3f,0,size*0.2f,size*0.2f,PI,2*PI);
      break;
      
      case 4: //switch
        switch(state){
          case 0:
            line(-size*0.3f,0,size*0.25f,-size*0.25f);
            line(-size/2,0,-size*0.3f,0);
            line(size/2,0,size*0.3f,0);
          break;
          
          case 1:
            line(-size*0.3f,0,size*0.3f,0);
            line(-size/2,0,-size*0.3f,0);
            line(size/2,0,size*0.3f,0);
          break;
          
          default:
            line(-size*0.3f,0,size*0.25f,-size*0.25f);
            line(-size/2,0,-size*0.3f,0);
            line(size/2,0,size*0.3f,0);
          break;
        }
      break;
      
      case 5: //VDC
        line(size*0.2f,0,size*0.3f,0);
        line(size*0.25f,size*0.05f,size*0.25f,-size*0.05f);
        line(-size*0.2f,0,-size*0.3f,0);
        ellipse(0,0,size,size);
      break;
      
      case 6: //VAC - Sinusoidal
        arc(-size*0.2f,0,size*0.4f,size*0.4f,PI,2*PI);
        arc(size*0.2f,0,size*0.4f,size*0.4f,0,PI);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5f,0,size*0.5f,0);
        stroke(255);
      break;
      
      case 7: //VAC - Triangle
        line(-size*0.4f,0,-size*0.2f,-size*0.2f);
        line(-size*0.2f,-size*0.2f,size*0.2f,size*0.2f);
        line(size*0.4f,0,size*0.2f,size*0.2f);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5f,0,size*0.5f,0);
        stroke(255);
      break;
      
      case 8: //VAC - Square
        line(-size*0.4f,0,-size*0.4f,-size*0.2f);
        line(-size*0.4f,-size*0.2f,0,-size*0.2f);
        line(0,-size*0.2f,0,size*0.2f);
        line(0,size*0.2f,size*0.4f,size*0.2f);
        line(size*0.4f,size*0.2f,size*0.4f,0);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5f,0,size*0.5f,0);
        stroke(255);
      break;
      
      case 9: //diode
        triangle(size*0.15f,-size*0.2f,size*0.15f,size*0.2f,-size*0.15f,0);
        line(-size/2,0,-size*0.15f,0);
        line(size/2,0,size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
      break;
      
      case 10: //NPN
        line(-size/2,0,-size*0.15f,0);
        line(-size*0.15f,-size*0.3f,-size*0.15f,size*0.3f);
        line(-size*0.15f,-size*0.15f,size*0.15f,-size*0.35f);
        line(-size*0.15f,size*0.15f,size*0.06f,size*0.29f);
        line(size*0.15f,-size*0.35f,size*0.15f,-size/2);
        line(size*0.15f,size*0.35f,size*0.15f,size/2);
        triangle(size*0.14f,size*0.34f,size*0.09f,size*0.25f,size*0.03f,size*0.33f);
        ellipse(0,0,size,size);
      break;
      
      case 11: //PNP
        line(-size/2,0,-size*0.15f,0);
        line(-size*0.15f,-size*0.3f,-size*0.15f,size*0.3f);
        line(-size*0.15f,-size*0.15f,size*0.15f,-size*0.35f);
        line(-size*0.06f,size*0.21f,size*0.15f,size*0.35f);
        line(size*0.15f,-size*0.35f,size*0.15f,-size/2);
        line(size*0.15f,size*0.35f,size*0.15f,size/2);
        triangle(-size*0.15f,size*0.15f,-size*0.03f,size*0.17f,-size*0.09f,size*0.25f);
        ellipse(0,0,size,size);
      break;
      
      case 12: //Oscilloscope
        line(-size*0.5f,-size*0.07f,-size*0.2f,-size*0.07f);
        line(-size*0.5f,size*0.07f,-size*0.2f,size*0.07f);
        line(-size*0.2f,-size*0.07f,size*0.45f,-size*0.02f);
        line(-size*0.2f,size*0.07f,size*0.45f,size*0.02f);
        line(size*0.45f,-size*0.02f,size*0.45f,size*0.02f);
        rect(-size*0.2f,0,size*0.04f,size*0.4f);
        ellipse(0,0,size,size);
      break;
      
      case 13: //VOLTMETER
        line(-size*0.05f,-size*0.07f,0,size*0.07f);
        line(size*0.05f,-size*0.07f,0,size*0.07f);
        
        ellipse(0,0,size,size);
        line(size*0.2f,0,size*0.3f,0);
        line(size*0.25f,size*0.05f,size*0.25f,-size*0.05f);
        line(-size*0.2f,0,-size*0.3f,0);
      break;
      
      case 14: //AMMETER
        line(-size*0.05f,size*0.07f,0,-size*0.07f);
        line(size*0.025f,size*0.02f,-size*0.025f,size*0.02f);
        line(size*0.05f,size*0.07f,0,-size*0.07f);
        
        ellipse(0,0,size,size);
        line(size*0.2f,0,size*0.3f,0);
        line(size*0.25f,size*0.05f,size*0.25f,-size*0.05f);
        line(-size*0.2f,0,-size*0.3f,0);
      break;
      
      case 15: //LED R
        fill(100,0,0);
        triangle(size*0.15f,-size*0.2f,size*0.15f,size*0.2f,-size*0.15f,0);
        noFill();        
        line(-size/2,0,-size*0.15f,0);
        line(size/2,0,size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
        line(size*0.1f,size*0.25f,0,size*0.35f);
        
                
        line(0,size*0.2f,-size*0.1f,size*0.3f);
        triangle(-size*0.05f,size*0.4f,-size*0.02f,size*0.33f,size*0.02f,size*0.37f);
        triangle(-size*0.15f,size*0.35f,-size*0.12f,size*0.28f,-size*0.08f,size*0.32f);
      break;
      
      case 16: //LED G
        fill(0,100,0);
        triangle(size*0.15f,-size*0.2f,size*0.15f,size*0.2f,-size*0.15f,0);
        noFill();
        line(-size/2,0,-size*0.15f,0);
        line(size/2,0,size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
        line(size*0.1f,size*0.25f,0,size*0.35f);
                
        line(0,size*0.2f,-size*0.1f,size*0.3f);
        triangle(-size*0.05f,size*0.4f,-size*0.02f,size*0.33f,size*0.02f,size*0.37f);
        triangle(-size*0.15f,size*0.35f,-size*0.12f,size*0.28f,-size*0.08f,size*0.32f);
      break;
      
      case 17: //LED B
        fill(0,0,100);
        triangle(size*0.15f,-size*0.2f,size*0.15f,size*0.2f,-size*0.15f,0);
        noFill();
        line(-size/2,0,-size*0.15f,0);
        line(size/2,0,size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
        line(size*0.1f,size*0.25f,0,size*0.35f);
                
        line(0,size*0.2f,-size*0.1f,size*0.3f);
        
        triangle(-size*0.05f,size*0.4f,-size*0.02f,size*0.33f,size*0.02f,size*0.37f);
        triangle(-size*0.15f,size*0.35f,-size*0.12f,size*0.28f,-size*0.08f,size*0.32f);
      break;
      
      case 18: //NMOSFET
        line(-size/2,0,-size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
        line(0,-size*0.3f,0,size*0.3f);
        
        line(size*0.1f,0,size*0.15f,0);
        line(0,size*0.2f,size*0.15f,size*0.2f);
        line(0,-size*0.2f,size*0.15f,-size*0.2f);
        
        line(size*0.15f,-size*0.2f,size*0.15f,-size/2);
        line(size*0.15f,0,size*0.15f,size/2);
        
        triangle(0,0,size*0.1f,size*0.05f,size*0.1f,-size*0.05f);
        
        ellipse(0,0,size,size);
      break;
      
      case 19: //PMOSFET
        line(-size/2,0,-size*0.15f,0);
        line(-size*0.15f,-size*0.2f,-size*0.15f,size*0.2f);
        line(0,-size*0.3f,0,size*0.3f);
        
        line(0,0,size*0.05f,0);
        line(0,size*0.2f,size*0.15f,size*0.2f);
        line(0,-size*0.2f,size*0.15f,-size*0.2f);
        
        line(size*0.15f,size*0.2f,size*0.15f,size/2);
        line(size*0.15f,0,size*0.15f,-size/2);
        
        triangle(size*0.15f,0,size*0.05f,size*0.05f,size*0.05f,-size*0.05f);
        
        ellipse(0,0,size,size);
      break;
      
      case 20: //IDC
        triangle(-size*0.25f,0,-size*0.15f,size*0.07f,-size*0.15f,-size*0.07f);
        
        line(size*0.25f,0,-size*0.15f,0);
        ellipse(0,0,size,size);
      break;
      
      case 21: //DC
        line(size*0.2f,0,size*0.3f,0);
        line(size*0.25f,size*0.05f,size*0.25f,-size*0.05f);
        line(-size*0.2f,0,-size*0.3f,0);
        ellipse(0,0,size,size);
      break;
      
      default: //wire
        line(-size/2,0,size/2,0);
      break;
    }
    popMatrix();
  }
  
  public String generateComponentText(int value, int prefixCode){
    if(!valueChange){
      return "";
    }else{
      return str(value) + str(intCodetoPrefix(prefixCode)) + unit;
    }
  }
  
  public String generateComponentTimeText(int value, int prefixCode){
    if(!timeChange){
      return "";
    }else{
      return str(value) + str(intCodetoPrefix(prefixCode)) + tunit;
    }
  }
  
}

public void drawOscilloscope(float size, float rotation){
  pushMatrix();
  rotate(radians(rotation));
  line(0, -size*0.07f, 0, size*0.07f);
  line(0, -size*0.07f, -size*0.25f, size*0.07f);
  line(0, size*0.07f, size*0.25f, -size*0.07f); 
  popMatrix();
}
public void mousePressed(){
  if(settingsOpen){
    if(mouseButton == LEFT){
      for(Slider thisslider:sliders){
        if(thisslider.clicked()){
          thisslider.select();
          return;
        }
      }
      Button settingsbutton = buttons.get(0);
      if(settingsbutton.clicked()){
        settingsbutton.doAction();
        return;
      }
    }
  }else{
    if(mouseButton == LEFT){
      for(Puck thispuck:pucks){
        if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
          if(removemode){
            thispuck.removeConnections();
            thispuck.removeGraph();
            pucks.remove(thispuck);
            removemode = false;
          }else if(graphmode){
            if(!thispuck.selectedComponent.name.equals("Oscilloscope")){ //IF IT ISN'T AN OSCILLOSCOPE
              Graph newGraph = new Graph(thispuck.x,thispuck.y,100,100,1, false);
              if(!thispuck.addGraph(newGraph)){ //if addgraph fails(already contains graph) then remove graph
                thispuck.removeGraph();
              }
              graphmode = false;
            }
          }else{
            thispuck.select();
          }
          return;
        }
      }
      for(Wire thiswire:wires){
        if(pointincircle(mouseX,mouseY,thiswire.x,thiswire.y,thiswire.size)){
          if(graphmode){
            Graph newGraph = new Graph(thiswire.x,thiswire.y,100,100,0, false);
            if(!thiswire.addGraph(newGraph)){ //if addgraph fails(already contains graph) then remove graph
              thiswire.removeGraph();
            }
            graphmode = false;
          }
          return;
        }
      }
      for(Graph thisgraph:graphs){
        if(!thisgraph.OSCILLOSCOPE){
          if(pointinrect(mouseX,mouseY,thisgraph.x,thisgraph.y,thisgraph.w,thisgraph.h)){
            thisgraph.select();
            return;
          }
        }
      }
      for(Button thisbutton:buttons){
        if(thisbutton.clicked()){
          thisbutton.doAction();
          return;
        }
      }
    }else if(mouseButton == RIGHT){
      if(circuitRun) return;
      for(Puck thispuck:pucks){
        if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
          thispuck.removeConnections();
          return;
        }
      }
    }
  }
}

public void mouseReleased(){
  for(Slider thisslider:sliders){
    thisslider.selected = false;
  }
  for(Puck thispuck:pucks){
    thispuck.selected = false;
  }
  for(Graph thisgraph:graphs){
    thisgraph.selected = false;
  }
}

public void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  for(Puck thispuck:pucks){
    if(thispuck.selected){
      thispuck.mouseRotate(e);
    }
  }
}

public void keyPressed(){
  //print(keyCode);
  if(keyCode == 88){ //X
    showDebug = !showDebug;
  }else if(keyCode == 83){
    savePucks();
  }else if(keyCode == 76){
    loadPucks();
  }
}
class Graph{
  float x, y;
  float anchorx, anchory;
  int graphColor;
  float w, h;
  float mouseoffx, mouseoffy;
  float[] values = new float[100];
  int novalues;
  float minval, maxval;
  String rangetext = "1V";
  int interval; //MILLISECONDS0
  int type; //0 - VOLTAGE; 1 - CURRENT
  boolean OSCILLOSCOPE;
  boolean selected;
  
  Graph(float x, float y, int novalues, int interval, int type, boolean osc){
    this.x = x;
    this.y = y;
    this.anchorx = x;
    this.anchory = y;
    this.w = width/4;
    this.h = height/4;
    colorMode(HSB, 360, 100, 100);
    this.graphColor = color(random(360),50,100);
    colorMode(RGB, 255, 255, 255);
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.novalues = novalues;
    this.minval = -oscRange;
    this.maxval = oscRange;
    this.interval = interval;
    this.type = type;
    this.selected = false;
    this.OSCILLOSCOPE = osc;
    resetValues();
  }
  
  public void show(int osccounter){
    drawAnchor();
    pushMatrix();
    translate(x,y);
    if(OSCILLOSCOPE){
      fill(graphColor);
      textAlign(LEFT);
      text("Src " + (osccounter + 1) + ":" + rangetext, -w*0.5f + (osccounter*w/4), -h*0.55f);
    }
    if(!OSCILLOSCOPE && pointinrect(mouseX,mouseY,x,y,w,h)){
      fill(255,128);
    }else{
      noFill();
    }
    stroke(255);
    strokeWeight(2);
    rect(0,0,w,h);
    rect(0,0,w*0.9f,h*0.8f);
    popMatrix();
    
    drawAxes();
    drawGraph(osccounter);
  }
  
  public void drawAnchor(){
    rectMode(CENTER);
    stroke(graphColor,128);
    strokeWeight(2);
    float mapyanch = map(min(maxval,max(minval,values[0])),minval,maxval,h*0.4f,-h*0.4f);
    line(x+w*0.45f,y+mapyanch,anchorx,anchory);
  }
  
  public void drawAxes(){
    pushMatrix();
    translate(x,y);
    noFill();
    stroke(255);
    strokeWeight(2);
    float mapzeroy = map(0,minval,maxval,h*0.4f,-h*0.4f);
    line(-w*0.45f,mapzeroy,w*0.45f,mapzeroy);
    line(-w*0.45f,h*0.4f,-w*0.45f,-h*0.4f);
    popMatrix();
  }
  
  public void drawGraph(int osccounter){
    pushMatrix();
    translate(x,y);
    if(OSCILLOSCOPE){
      fill(graphColor);
      textAlign(LEFT);
      text("Src " + (osccounter + 1) + ":" + rangetext, -w*0.5f + (osccounter*w/4), -h*0.55f);
      textAlign(LEFT,CENTER);
      text(rangetext,-w*0.475f + (osccounter*w/4),-h*0.45f);
      text("-" + rangetext,-w*0.475f + (osccounter*w/4),h*0.45f);
    }
    //if(type == 0){
    //  stroke(0,200,255);
    //}else{
    //  stroke(255,0,255);
    //}
    noFill();
    strokeWeight(2);
    stroke(graphColor);
    beginShape();
    for(int i = 0; i < values.length; i++){
      float mapxval = map(i,0,values.length-1,w*0.45f,-w*0.45f);
      float mapyval = map(min(maxval,max(minval,values[i])),minval,maxval,h*0.4f,-h*0.4f);
      vertex(mapxval,mapyval);
    }
    endShape();
    popMatrix();
  }
  
  public void move(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void setAnchor(float x, float y){
    anchorx = x;
    anchory = y;
  }
  
  public void select(){
    selected = true;
    mouseoffx = mouseX - x;
    mouseoffy = mouseY - y;
  }
  
  public void mouseMove(){
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
  }
  
  
  public void addValue(float val){
    for(int i = values.length - 1; i > 0; i--){
      values[i] = values[i-1];
    }
    values[0] = val;
    
    if(!OSCILLOSCOPE){
      if(val > maxval){
        maxval = val;
      }else if(val < minval){
        minval = val;
      }
    }
  }
  
  public void resetValues(){
    for(int i = 0; i < values.length; i++){
      values[i] = 0;
    }
  }
  
  public void setMaxMin(float range, String rangetext){
    this.maxval = range;
    this.minval = -range;
    this.rangetext = rangetext;
  }
  
  public void updateMax(float max){
    this.maxval = max;
  }
  
  public void updateMin(float min){
    this.minval = min;
  }
  
  public void run(){
    if(selected && !OSCILLOSCOPE){
      mouseMove();
    }
  }
}

public void showGraphs(){
  int osccounter = 0;
  for(Graph thisgraph:graphs){
    thisgraph.run();
    if(thisgraph.OSCILLOSCOPE){
      if(osccounter == 0){
        thisgraph.show(osccounter);
      }else{
        thisgraph.drawAnchor();
        thisgraph.drawGraph(osccounter);
      }
      osccounter++;
    }else{
      thisgraph.show(0);
    }
  }
}

public void updateOSCgraphpos(float x, float y){
  for(Graph thisgraph:graphs){
    if(thisgraph.OSCILLOSCOPE){
      thisgraph.move(x,y);
    }
  }
}
class Icon{
  String name;
  Icon(String name){
    this.name = name;
  }
  
  public void display(float x, float y, float size, boolean nf, int fc, int sc, float sw){
    pushMatrix();
    translate(x,y);
    scale(size);
    if(nf){
      noFill();
    }else{
      fill(fc);
    }
    if(sw == 0){
      noStroke();
    }else{
      strokeWeight(sw/size);
      stroke(sc);
    }
    switch(name){
      case "chip":
        rectMode(CENTER);
        rect(0,0,1.7f,1.7f,0.3f,0.3f,0.3f,0.3f);
        rect(0,0,1.4f,1.4f,0.1f,0.1f,0.1f,0.1f);
        ellipse(-0.45f,-0.45f,0.1f,0.1f);
        line(0.85f,0,1,0);
        line(0.85f,0.2f,1,0.2f);
        line(0.85f,0.4f,1,0.4f);
        line(0.85f,-0.2f,1,-0.2f);
        line(0.85f,-0.4f,1,-0.4f);
        line(-0.85f,0,-1,0);
        line(-0.85f,0.2f,-1,0.2f);
        line(-0.85f,0.4f,-1,0.4f);
        line(-0.85f,-0.2f,-1,-0.2f);
        line(-0.85f,-0.4f,-1,-0.4f);
        line(0,0.85f,0,1);
        line(0.2f,0.85f,0.2f,1);
        line(0.4f,0.85f,0.4f,1);
        line(-0.2f,0.85f,-0.2f,1);
        line(-0.4f,0.85f,-0.4f,1);
        line(0,-0.85f,0,-1);
        line(0.2f,-0.85f,0.2f,-1);
        line(0.4f,-0.85f,0.4f,-1);
        line(-0.2f,-0.85f,-0.2f,-1);
        line(-0.4f,-0.85f,-0.4f,-1);
      break;
      
      case "wrench":
        rotate(PI/6);
        line(0.15f,-0.4f,0.15f,0.4f);
        line(-0.15f,-0.4f,-0.15f,0.4f);
        arc(0,-0.7f,0.6f,0.6f,2*PI/3,4*PI/3);
        arc(0,-0.7f,0.6f,0.6f,5*PI/3,7*PI/3);
        arc(0,0.7f,0.6f,0.6f,2*PI/3,4*PI/3);
        arc(0,0.7f,0.6f,0.6f,5*PI/3,7*PI/3);
        line(-0.15f,-0.9f,-0.15f,-0.7f);
        line(0.15f,-0.9f,0.15f,-0.7f);
        line(-0.15f,-0.7f,0.15f,-0.7f);
        line(-0.15f,0.9f,-0.15f,0.7f);
        line(0.15f,0.9f,0.15f,0.7f);
        line(-0.15f,0.7f,0.15f,0.7f);
      break;
      
      case "knob":

        ellipse(0,0,2,2);
        line(-1,0,-0.8f,0);
        line(1,0,0.8f,0);
        line(0,-1,0,-0.8f);
        line(0,1,0,0.8f);
        ellipse(0,0,1,1);
        rotate(PI/8);
        line(0,0,0,-0.5f);
      break;
      
      case "gear":
        ellipse(0,0,1,1);
        for(int i = 0; i < 8; i++){
          arc(0,0,1.6f,1.6f,-PI/8,0);
          line(0.8f,0,1,0);
          rotate(PI/8);
          arc(0,0,2,2,-PI/8,0);
          line(0.8f,0,1,0);
          rotate(PI/8);
        }
      break;
      
      case "time":
        ellipse(0,0.125f,1.75f,1.75f);
        line(0.25f,-1,-0.25f,-1);
        line(0,-1,0,-0.75f);
        line(0,0,0,-0.5f);
        rotate(-PI/4);
        line(0,0,0,-0.5f);
      break;
      
      default:
      break;
    } 
    popMatrix();
    
  }
  
  
  
}
public void addPucksRandom(int num){
  for(int i = 0; i < num; i++){
    pucks.add(new Puck(i, random(puckSize,width - puckSize),random(puckSize, height - puckSize),puckSize, shakeSettings, scrollSettings));
  }
}

public void addPucks(int num){
  for(int i = 0; i < num; i++){
    pucks.add(new Puck(i, 0, 0, puckSize, shakeSettings, scrollSettings));
  }
}

public void addWires(int num){
  for(int i = 0; i < num; i++){
    wires.add(new Wire(i));
  }
}

public void createComponents(){
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

public void createCategories(){
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

public void createZones(){
  //zones.add(new Zone(0, "Component Selection", 0, width/4,height*0.9,width/2,height*0.2, chipIC));
  //zones.add(new Zone(1, "Component Value Change", 0, width*3/4,height*0.9,width/2,height*0.2, knobIC));
  zones.add(new Zone(0, "Component Category Selection", 0, width*7/16,height*0.9f,width*3/8,height*0.2f, chipIC));
  zones.add(new Zone(1, "Component Value Change", 0, width*7/8,height*0.9f,width/4,height*0.2f, knobIC));
  zones.add(new Runzone(2, "Start Simulation", 1, width - puckSize*0.7f , puckSize*0.7f ,puckSize*1.1f,puckSize*1.1f, null));
  zones.add(new Zone(3, "Category Component Change", 0, width/8,height*0.9f,width/4,height*0.2f, wrenIC));
  zones.add(new Zone(4, "Component Time Change", 0, width*11/16,height*0.9f,width/8,height*0.2f, timeIC));
  runzone = (Runzone) zones.get(2);
}

public void createButtons(){
  buttons.add(new Button("Settings", height*2/80,height*3/80,height*3/80));
  buttons.add(new Button("AddPucks", height*2/80,height*7/80,height*3/80));
  buttons.add(new Button("RemovePucks", height*2/80,height*11/80,height*3/80));
  //buttons.add(new Button("AddGraph", height*2/80,height*15/80,height*3/80));
}

public void createSliders(){
  sliders.add(new Slider("Scrollsen", width*0.6f, height*0.2f, width*0.5f, height*2/80));
  sliders.add(new Slider("Shakesen", width*0.6f, height*0.3f, width*0.5f, height*2/80));
  sliders.add(new Slider("DiscSize", width*0.6f, height*0.4f, width*0.5f, height*2/80));
  //sliders.add(new Slider("DiscRotType", width*0.6, height*0.5, width*0.5, height*2/80));
}
class Button{
  String purpose;
  float x, y;
  float size;
  
  Button(String purpose, float x, float y, float size){
    this.purpose = purpose;
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  
  public void display(){
    textAlign(LEFT,CENTER);
    switch(purpose){
      case "AddPucks":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Add Disc", x + size/1.5f, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        line(size/4,0,-size/4,0);
        line(0,size/4,0,-size/4);
        popMatrix();
      break;
      
      case "RemovePucks":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Remove Disc", x + size/1.5f, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        line(size/4,0,-size/4,0);
        popMatrix();
      break;
      
      case "AddGraph":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Toggle Graph", x + size/1.5f, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        
        line(size/4,0,-size/4,0);
        line(-size/4,size/4,-size/4,-size/4);
        stroke(255,128);
        arc(size/8,0,size/4,size/2,0,PI);
        arc(-size/8,0,size/4,size/2,PI,2*PI);
        popMatrix();
      break;
      
      case "Settings":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Settings", x + size/1.5f, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        
        gearIC.display(0,0,size/3,true,color(0),color(255),2);
        popMatrix();
      break;
      
      default:
      break;
    }
  }
  
  
  public boolean clicked(){
    return pointincircle(mouseX,mouseY,x,y,size);
  }
  
  public void doAction(){
    switch(purpose){
      case "AddPucks":
        removemode = false;
        pucks.add(new Puck(pucks.size()+1, x, y,puckSize, shakeSettings, scrollSettings));
      break;
      
      case "RemovePucks":
        graphmode = false;
        removemode = !removemode;
      break;
      
      case "AddGraph":
        removemode = false;
        graphmode = !graphmode;
      break;
      
      case "Settings":
        removemode = false;
        settingsOpen = !settingsOpen;
      break;
      
      default:
      break;
    }
  }
}

class Slider{
  String purpose;
  float x, y;
  float size;
  boolean selected;
  float ballsize, ballval, ballx;
  
  Slider(String purpose, float x, float y, float size, float ballsize){
    this.purpose = purpose;
    this.x = x;
    this.y = y;
    this.size = size;
    this.ballsize = ballsize;
    this.ballval = 0.5f;
    this.selected = false;
    mapballx();
  }
  
  
  public void display(){
    switch(purpose){
      case "Shakesen":
        stroke(255);
        strokeWeight(2);
        pushMatrix();
        translate(x,y);
        line(-size/2,-ballsize/2,-size/2,ballsize/2);
        line(size/2,-ballsize/2,size/2,ballsize/2);
        line(0,-ballsize/2,0,ballsize/2);
        line(-size/2,0,size/2,0);
        if(pointincircle(mouseX,mouseY,x+ballx,y,ballsize) || selected){
          fill(128);
        }else{
          fill(0);
        }
        ellipse(ballx,0,ballsize,ballsize);
        
        if(selected){
          fill(255);
          textAlign(CENTER);
          text("More Sensitive", size/2, -ballsize);
          text("Less Sensitive", -size/2, -ballsize);
        }
        popMatrix();
      break;
      
      case "Scrollsen":
        stroke(255);
        strokeWeight(2);
        pushMatrix();
        translate(x,y);
        line(-size/2,-ballsize/2,-size/2,ballsize/2);
        line(size/2,-ballsize/2,size/2,ballsize/2);
        line(0,-ballsize/2,0,ballsize/2);
        line(-size/2,0,size/2,0);
        if(pointincircle(mouseX,mouseY,x+ballx,y,ballsize) || selected){
          fill(128);
        }else{
          fill(0);
        }
        ellipse(ballx,0,ballsize,ballsize);
        
        if(selected){
          fill(255);
          textAlign(CENTER);
          text("More Sensitive", size/2, -ballsize);
          text("Less Sensitive", -size/2, -ballsize);
        }
        popMatrix();
      break;
      
      case "DiscSize":
        stroke(255);
        strokeWeight(2);
        pushMatrix();
        translate(x,y);
        line(-size/2,-ballsize/2,-size/2,ballsize/2);
        line(size/2,-ballsize/2,size/2,ballsize/2);
        line(0,-ballsize/2,0,ballsize/2);
        line(-size/2,0,size/2,0);
        if(pointincircle(mouseX,mouseY,x+ballx,y,ballsize) || selected){
          fill(128);
        }else{
          fill(0);
        }
        ellipse(ballx,0,ballsize,ballsize);
        
        if(selected){
          fill(255);
          textAlign(CENTER);
          text("More Sensitive", size/2, -ballsize);
          text("Less Sensitive", -size/2, -ballsize);
        }
        popMatrix();
      break;
      
      default:
      break;
    }
  }
  
  public void mapballx(){
    ballx = map(ballval,0,1,-size/2,size/2);;
  }
  
  
  public boolean clicked(){
    return pointincircle(mouseX,mouseY,x+ballx,y,ballsize);
  }
  
  public void doAction(){
    switch(purpose){
      case "Shakesen":
        shakeSettings = ballval;
        for(Puck tp:pucks){
          tp.setShakeSettings(shakeSettings);
        }
      break;
      
      case "Scrollsen":
        scrollSettings = ballval;
        for(Puck tp:pucks){
          tp.setScrollSettings(scrollSettings);
        }
      break;
      
      case "DiscSize":
        for(Puck tp:pucks){
          tp.setPuckSize(ballval);
        }
      break;
      
      case "DiscRotType":
      break;
      
      default:
      break;
    }
  }
  public void select(){
    selected = true;
  }
  
  public void mouseMove(){
    ballx = min(max(mouseX-x,-size/2),size/2);
    ballval = map(ballx,-size/2,size/2,0,1);
  }
  
  public void run(){
    if(selected){
      mouseMove();
      doAction();
    }
  }
}
public float bezierLength(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2, float precision) {
  if (precision <= 0 || precision >= 1) return -1;

  float l = 0;
  float i = 0;
  while (i+precision <= 1) {
    float xPos1 = bezierPoint(x1, cx1, cx2, x2, i);
    float xPos2 = bezierPoint(x1, cx1, cx2, x2, i+precision);
    float yPos1 = bezierPoint(y1, cy1, cy2, y2, i);
    float yPos2 = bezierPoint(y1, cy1, cy2, y2, i+precision);
    l += dist(xPos1, yPos1, xPos2, yPos2);
    //println(i+precision);
    i += precision;
  }

  return l;
}

public float limdegrees(float indegrees){ //keeps input angle between 0 - 360
  if(indegrees > 360){
    return indegrees % 360;
  }else if(indegrees < 0){
      return indegrees % 360 + 360;
  }else{
    return indegrees;
  }
}

public float sigmoid(float input){
  return 2/(1+exp(-input)) - 1;
}

public float limradians(float inrads){ //keeps input angle between 0 - 2PI
  if(inrads > 2*PI){
    return inrads % (2*PI);
  }else if(inrads < 0){
      return inrads % (2*PI) + 2*PI;
  }else{
    return inrads;
  }
}

public boolean withinradians(float inrad, float lowrad, float hirad){ // returns true if inrad is within angle bounds (lowrad is the lower bound; hirad is the higher bound)
  if(lowrad > hirad){
    return (inrad > lowrad && inrad <= 2*PI) || (inrad >= 0 && inrad < hirad);
  }else{
    return inrad > lowrad && inrad < hirad;
  }
}

public float maxangdiff(float radone, float radtwo){ //returns larger of the two possible difference between two vector angles
  float diff = abs(radone - radtwo);
  return (diff < PI) ? 2 * PI - diff : diff;
}

public float minangdiff(float radone, float radtwo){ //returns smaller of the two possible difference between two vector angles
  float diff = abs(radone - radtwo);
  return (diff < PI) ? diff : 2 * PI - diff;
}

public boolean mspassed(int starttime, int interval){
  return millis() > starttime + interval;
}

public PVector limtoscreen(PVector limvect){
  return limvect.set(max(0,min(width,limvect.x)),max(0,min(height*0.8f,limvect.y)));
  
}

public String prefixCodetoNGCode(char prefix){
  switch(prefix){
    case 'T': //tera
      return "T";
    case 'G': //giga
      return "G";
    case 'M': //mega
      return "Meg";
    case 'k': //kilo
      return "K";
    case 'N': //normal??
      return "";
    case 'm': //milli
      return "m";
    case 'µ': //micro
      return "u";
    case 'n': //nano 
      return "n";
    case 'p': //pico 
      return "p";
    default:
      return "";
  }
}

public String intCodetoNGCode(int intCode){
  switch(intCode){
    case 4: //tera
      return "T";
    case 3: //giga
      return "G";
    case 2: //mega
      return "Meg";
    case 1: //kilo
      return "K";
    case 0: //normal??
      return "";
    case -1: //milli
      return "m";
    case -2: //micro
      return "u";
    case -3: //nano 
      return "n";
    case -4: //pico 
      return "p";
    default:
      return "";
  }
}

public int prefixCodetoInt(char prefix){
  switch(prefix){
    case 'T': //tera
      return 4;
    case 'G': //giga
      return 3;
    case 'M': //mega
      return 2;
    case 'k': //kilo
      return 1;
    case 'N': //normal??
      return 0;
    case 'm': //milli
      return -1;
    case 'µ': //micro
      return -2;
    case 'n': //nano 
      return -3;
    case 'p': //pico 
      return -4;
    default:
      return 0;
  }
}
//1234567890pnµmkMGTFHVΩ
public char intCodetoPrefix(int intCode){
  switch(intCode){
    case 4:
      return 'T'; //tera
    case 3:
      return 'G'; //giga
    case 2:
      return 'M'; //mega
    case 1:
      return 'k'; //kilo
    case 0:
      return '\0'; //normal??
    case -1:
      return 'm'; //milli
    case -2:
      return 'µ'; //micro
    case -3:
      return 'n'; //nano 
    case -4:
      return 'p'; //pico 
    default:
      return 'N';
  }
}

public int intCodetoColour(int intCode, int alpha){
  switch(intCode){
    case 4: //tera
      return color(255,alpha);
    case 3: //giga
      return color(150,alpha);
    case 2: //mega
      return color(130,0,255,alpha);
    case 1: //kilo
      return color(0,150,255,alpha);
    case 0:  //normal??
      return color(20,255,0,alpha); //green
    case -1: //milli
      return color(255,240,0,alpha); //yellow
    case -2: //micro
      return color(255,150,0,alpha); //orange
    case -3: //nano 
      return color(255,0,0,alpha); //red
    case -4: //pico 
      return color(180,120,30,alpha); //brown
    default:
      return color(0); //black
  }
  
}

//void lerpColorRing(color ca, color cb, float x, float y, float r, float sweight, int angstart, int angend){
//  int angdiff = angend - angstart;
//  strokeWeight(sweight);
//  for(int a = angstart; a < angend; a++){
//    stroke(lerpColor(ca,cb,float(a-angstart)/float(angdiff))); //val ring color
//    arc(x,y,r,r,radians(angstart), radians(angstart + a));
//  }
//}
class Puck{
  boolean MASTERPUCK = false;
  float MASTERrotation = 280;
  int selectedMASTER = 0;
  int id;
  float x, y;
  float size, aurasize, ringthickness;
  float baserotation, prebaserotation;
  float rotation, catrotation, valrotation, timerotation, staterotation, comrotation;
  float scrollmult;
  boolean selected;
  float mouseoffx, mouseoffy;
  int currZone;
  
  ComponentCategory selectedCategory;
  Component selectedComponent;
  int selectedvalue, selectedprefix, selectedstate, selectedTvalue, selectedTprefix;
  int catno = categories.size();
  int comno = components.size();
  
  IntList beginconnection = new IntList();
  IntList connectclock = new IntList();
  IntList connectms = new IntList();
    
  Wire[] connectedWires;
  float[] voltages = new float[3]; //ALL: 0 - voltage || BJT: 0 - VBE, 1 - VCE || MOSFET: 0 - VDS, 1 - VGS, 2 - VBS
  float[] currents = new float[3]; //ALL: 0 - current || BJT: 0 - iC, 1 - iB, 2 - iE || MOSFET: 0 - iD, 1 - iG, 2 - iS
  
  String valtext, timetext;
  int menuclock = 0, menums = millis(), menualpha;
  boolean menushow;
  
  float shakedir;
  float shakeAngThresh = PI/2, shakeMagThresh = 10, shakex, shakey; //ADJUST SHAKE SENSITIVITY - ANG/MAG/COUNTER/SAMPPERIOD
  int shakeCounterThresh = 3, shakeCounter = 0, shakems = millis(), shakeDecayPeriod = 1000;
  boolean shakeReset = false;
  
  Graph puckGraph;
  float voltageAcross, currentThrough; //FOR OSCILLOSCOPE AND VOLTMETER, AMMETER
  
  IntList errors = new IntList();
  
  Puck(int id, float x, float y, float size, float shakeSen, float scrollSen){ //size being 100
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.aurasize = size*0.2f; //20
    this.ringthickness = size*0.1f; //10

    this.baserotation = random(360);
    this.prebaserotation = baserotation;
    
    this.rotation = 0;
    this.catrotation = 0;
    this.valrotation = 0;
    this.timerotation = 0;
    this.staterotation = 0;
    this.comrotation = 0;
    
    this.selected = false; 
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.currZone = checkZone();
    
    this.selectedCategory = categories.get(0);
    resetCategory();
    
    for(int i = 0; i < 3; i++){
      beginconnection.append(0);
      connectclock.append(0);
      connectms.append(millis());
    }
    //change later?
    this.connectedWires = new Wire[3];
    for(int w = 0; w < connectedWires.length; w++){
      connectedWires[w] = null;
    }
    for(int e = 0; e < voltages.length; e++){
      voltages[e] = 0;
      currents[e] = 0;
    }
    this.shakex = x;
    this.shakey = y;
    this.shakedir = -1;
    setShakeSettings(shakeSen);
    setScrollSettings(scrollSen);
    this.puckGraph = null;
    this.voltageAcross = 0;
  }
  
  //=======================================================
  //==================== DISPLAY STUFF ====================
  //=======================================================
  public void display(){
    pushMatrix();
    translate(x,y);
    if(MASTERPUCK){
      drawDisc();
      drawComponent();
    }else{
      drawAura();
      //===== DRAW MENU BACKING =====
      drawMenuBack();
      //===== DRAW THE DISC =====
      drawDisc();
      //===== DRAW THE COMPONENT ON THE DISC =====
      drawComponent();
      //===== DRAW THE MENUS ABOVE THE DISC =====
      drawMenu();
      //if(showDebug){
      //drawRotationMarker();
      //}
      
      if(showDebug){
        fill(255);
        text("ID: " + id, 0, -75);
        text(selectedComponent.name,0,-115);
        text(selectedCategory.name,0,-100);
        if(selectedCategory.name.equals("Active Components")){
          if(selectedComponent.name.endsWith("BJT")){
            text("IC: " + currents[0], 100, -15);
            text("IB: " + currents[1], 100, 0);
            text("IE: " + currents[2], 100, 15);
          }else{
            text("ID: " + currents[0], 100, -15);
            text("IG: " + currents[1], 100, 0);
            text("IS: " + currents[2], 100, 15);
          }
          
        }else{
          text("I: " + currents[0], 100, 0);
        }
        if(selectedComponent.name.equals("Capacitor") || selectedComponent.name.equals("Diode") || selectedComponent.name.equals("LED")){
          text("V: " + voltages[0], 100, -15);
        }
      }
    }
    
    drawRotationMarker();
    popMatrix();
    if(MASTERPUCK){
      drawMenu();
    }
    if(puckGraph != null){
      puckGraph.setAnchor(x,y);
    }
  }
  
  public void drawDisc(){
    stroke(255);
    strokeWeight(ringthickness);
    
    if(selected){
      //fill(50);
      float mapshake = map(shakeCounter,0,shakeCounterThresh,50,150);
      fill(mapshake,50,50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        if(removemode){
          stroke(128,0,0);
          fill(128,0,0);
        }else if(graphmode){
          stroke(0,0,128);
          fill(0,0,128);
        }else{
          fill(128);
        }
      }else{
        if(currZone != -1){
          fill(50);
        }else{
          fill(0);
        }
      }
    }
    ellipse(0, 0, size-ringthickness,size-ringthickness);
  }
  
  public void drawComponent(){
    if(MASTERPUCK){ //ON-OFF ICON
      noFill();
      stroke(255,255-menualpha);
      strokeWeight(2);
      
      float offsetamount = (size - ringthickness)*0.20f;
      arc(0,0,offsetamount,offsetamount,-PI/2+PI/5,1.5f*PI-PI/5);
      line(0,0,0,-offsetamount*0.5f);
      fill(255,menualpha);
      float mult = pow(2,selectedMASTER);
      text("x" + mult,0,0);
    }else{
      if(circuitRun){   //SPECIAL DRAWS FOR COMPONENTS IN CIRCUIT RUN MODE
        fill(255);
        textAlign(CENTER,CENTER);
        if(selectedComponent.name.equals("Oscilloscope")){ //OSCILLOSCOPE
          if(puckGraph != null){
            stroke(puckGraph.graphColor);
          }else{
            stroke(255);
          }
          strokeWeight(3);
          drawOscilloscope(size, rotation);
        }else if(selectedComponent.name.equals("Voltmeter")){ //VOLTMETER
          text(voltageAcross + "V",0,0);
        }else if(selectedComponent.name.equals("Ammeter")){ //AMMETER
          text(-currents[0] + "A",0,0);
        //}else if(selectedComponent.name.equals("LED")){ //LED
        //  text(currents[0],0,0);
        //  float brightness = min(100,map(currents[0],0,0.05,0,100));
        //  noStroke();
        //  fill(255,0,0,brightness);
        //  ellipse(0,0,500,500);
        }else{
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(timetext,0,-size/4);
          text(valtext,0,size/4);
          selectedComponent.drawComponent(0,0,size-15,rotation,2, false, selectedstate);
        }
      }else{
        if(currZone == 1 || currZone == 4){ //DRAW FOR VALUE OR TIME SELECTION
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(timetext,0,-size/4);
          text(valtext,0,size/4);
          stroke(255,map(menualpha,0,255,255,50));
          strokeWeight(2);
          noFill();
          selectedComponent.drawComponent(0,0,size-15,rotation,2, true, selectedstate);
        }else if(currZone == 3 && selectedCategory.cat.size() <= 1){ //DRAW DIMMER FOR COMPONENTS WITHOUT CATEGORY
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(timetext,0,-size/4);
          text(valtext,0,size/4);
          stroke(255,map(menualpha,0,255,255,50));
          strokeWeight(2);
          noFill();
          selectedComponent.drawComponent(0,0,size-15,rotation,2, true, selectedstate);
        }else{ // ============= NOMRAL DRAW =============
          fill(255,100);
          textAlign(CENTER,CENTER);
          text(timetext,0,-size/4);
          text(valtext,0,size/4);
          if(errors.hasValue(404)){ //WIRE ERROR
            stroke(255,0,0);
            strokeWeight(2);
            noFill();
            selectedComponent.drawComponent(0,0,size-15,rotation,2, true, selectedstate);
          }else{
            selectedComponent.drawComponent(0,0,size-15,rotation,2, false, selectedstate);
            
          }
          
        }
      }
    }
  }
  
  public void drawAura(){
    float totsize = size + aurasize;
    float rotrad = radians(rotation);
    int terminals = selectedComponent.terminals;
    if(currZone == -1 && !circuitRun){ //DRAW NORMAL AURAS
      fill(255,128);
      noStroke();
      ellipse(0, 0, totsize, totsize);
      pushMatrix();
      rotate(rotrad);
      if(terminals == 3){
        rotate(-2*PI/12);
      }
      for(int i = 0; i < terminals; i++){
        stroke(0);
        strokeWeight(1);
        float connectAng = 2*PI/terminals;
        
        line(0, 0, 0, -totsize/2);
        
        int currclock = connectclock.get(i);
        fill(255,map(currclock,0,100,50,255));
        noStroke();
        float connectRad = map(currclock,0,100,0,aurasize);
        arc(0,0,size+connectRad,size+connectRad,-PI/2,-PI/2+connectAng);
        if(errors.hasValue(i)){ //DRAW RED AURA FOR ERRORS
          fill(255,0,0);
          noStroke();
          arc(0,0,totsize,totsize,-PI/2,-PI/2+connectAng);
        }
        rotate(connectAng);
      }
      popMatrix();
    }
  }
  
  public void drawPointers(){
    fill(255,menualpha);
    noStroke();
    pushMatrix();
    if(currZone == 0){
      rotate(radians(catrotation));
    }else if(currZone == 1){
      rotate(radians(valrotation));
    }else if(currZone == 2){
      rotate(radians(MASTERrotation));
    }else if(currZone == 3){
      rotate(radians(comrotation));
    }else if(currZone == 4){
      rotate(radians(timerotation));
    }else if(currZone == -1 && circuitRun){
      rotate(radians(staterotation));
    }
    triangle(-size*0.1f,-size*0.45f,size*0.1f,-size*0.45f,0,-size*0.55f);
    popMatrix();
  }
  
  public void drawMenuBack(){
    if(menushow){
      float menuBackrad = map(menualpha,0,255,size,size+aurasize*4);
      if(currZone == 0){
        fill(menualpha,50);
        noStroke();
        ellipse(0,0,menuBackrad,menuBackrad);
      }else if(currZone == 3){
        if(selectedCategory.cat.size() > 1){
          fill(menualpha,50);
          noStroke();
          ellipse(0,0,menuBackrad,menuBackrad);
        }
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          fill(menualpha,50);
          noStroke();
          ellipse(0,0,menuBackrad,menuBackrad);
        }
      }
    }
  }
  
  public void drawRotationMarker(){
    pushMatrix();
    rotate(radians(baserotation));
    fill(255,0,0);
    noStroke();
    rectMode(CENTER);
    rect(0,(size-ringthickness)/2,ringthickness/2,ringthickness/2);
    popMatrix();
  }
  
  public void drawMenu(){
    if(menushow){
      if(currZone == 0){
        drawCategoryMenu();
      }else if(currZone == 1){
        if(selectedComponent.valueChange){
          drawValMenu(selectedprefix, selectedvalue, valrotation);
          fill(255, menualpha);
          textAlign(CENTER,CENTER);
          text(valtext,0,size/4);
        }else{
          hideMenu();
        }
      }else if(currZone == 2){
        if(MASTERPUCK){
          if(runzone.state == 3 || runzone.state == 4){
            drawMasterMenu();
          }else{
            hideMenu();
          }
        }else{
          hideMenu();
        }
      }else if(currZone == 3){
        if(selectedCategory.cat.size() > 1){
          drawComponentMenu();
        }else{
          hideMenu();
        }
      }else if(currZone == 4){
        if(selectedComponent.timeChange){
          drawValMenu(selectedTprefix, selectedTvalue, timerotation); 
          fill(255, menualpha);
          textAlign(CENTER,CENTER);
          text(timetext,0,-size/4);
        }else{
          hideMenu();
        }
      }else if(currZone == -1){
        if(circuitRun && selectedComponent.noStates > 1){
          drawStateMenu();
        }
      }
    }
  }
  
  public void drawComponentMenu(){
    drawPointers();
    stroke(255,menualpha);
    strokeWeight(1);
    noFill();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      
      pushMatrix();
      int totcomponents = selectedCategory.cat.size();
      float frac = 1/PApplet.parseFloat(totcomponents);
      for(int i = 0; i < totcomponents; i++){
        Component catComponent = selectedCategory.cat.get(i);
        rotate(frac*PI);
        if(selectedComponent.equals(catComponent)){
          strokeWeight(3);
          catComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, selectedstate);
          strokeWeight(1);
        }else{
          catComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, selectedstate);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
      fill(255,menualpha);
      text(selectedComponent.name, 0, -size);
    }else{
      menushow = false;
    }
  }
  
  public void drawStateMenu(){
    drawPointers();
    stroke(255,menualpha);
    strokeWeight(1);
    noFill();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      
      pushMatrix();
      int totstates = selectedComponent.noStates;
      float frac = 1/PApplet.parseFloat(totstates);
      for(int i = 0; i < totstates; i++){
        rotate(frac*PI);
        if(selectedstate == i){
          strokeWeight(3);
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, i);
          strokeWeight(1);
        }else{
          selectedComponent.drawComponent(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, i);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
    }else{
      menushow = false;
    }
  }
  
  public void drawCategoryMenu(){
    drawPointers();
    stroke(255,menualpha);
    strokeWeight(1);
    noFill();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      
      pushMatrix();
      float frac = 1/PApplet.parseFloat(catno);
      for(int i = 0; i < catno; i++){
        rotate(frac*PI);
        if(selectedCategory.equals(categories.get(i))){
          strokeWeight(3);
          categories.get(i).drawCategory(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, 0);
          strokeWeight(1);
        }else{
          categories.get(i).drawCategory(0,-size/2-aurasize,size/4,frac*PI+PI/2,2, true, 0);
          strokeWeight(1);
        }
        rotate(frac*PI);
        line(0,-size/2,0,-(size/2)-aurasize*2);
      }
      popMatrix();
      fill(255,menualpha);
      text(selectedCategory.name, 0, -size);
    }else{
      menushow = false;
    }
  }
  
  public void drawValMenu(int prefix, int value, float valrot){
    drawPointers();
    noFill();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      
      strokeWeight(aurasize/2);
      stroke(intCodetoColour(prefix-1,menualpha));
      ellipse(0,0,size+aurasize*1.5f,size+aurasize*1.5f); //base ring color
      stroke(lerpColor(intCodetoColour(prefix-1,menualpha),intCodetoColour(prefix,menualpha),PApplet.parseFloat(value)/1000), menualpha); //val ring color
      arc(0,0,size+aurasize*1.5f,size+aurasize*1.5f, 0-PI/2, radians(valrot)-PI/2);
      
      stroke(255,menualpha);
      strokeWeight(1);
      ellipse(0,0,size+aurasize,size+aurasize);
      ellipse(0,0,size+aurasize*2,size+aurasize*2);
      
      pushMatrix();
      rotate(radians(valrot));
      fill(255, menualpha);
      noStroke();
      ellipse(0,-size/2-aurasize*0.75f,aurasize/2,aurasize/2);
      popMatrix();
      
      pushMatrix();
      stroke(255, menualpha);
      strokeWeight(1);
      for(int i = 0; i < 10; i++){
        for(int j = 0; j < 9; j++){
          rotate(radians(3.6f));
          line(0,-size/2-aurasize,0,-size/2-aurasize*1.25f);
        }
        rotate(radians(3.6f));
        line(0,-size/2-aurasize,0,-size/2-aurasize*1.5f);
      }
      popMatrix();
    }else{
      menushow = false;
    }
  }
  
  public void drawMasterMenu(){
    pushMatrix();
    translate(x,y);
    drawPointers();
    popMatrix();
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
      runzone.displayBar(menualpha,aurasize,selectedMASTER);
    }else{
      menushow = false;
    }
  }
  
  //===========================================================
  //==================== INTERACTION STUFF ====================  
  //===========================================================

  public void select(){
    selected = true;
    mouseoffx = mouseX - x;
    mouseoffy = mouseY - y;
  }
  
  public void resetShake(){
    if(!shakeReset){
      shakedir = -1;
      shakeCounter = 0;
      shakems = millis();
      shakeReset = true;
    }
  }
  
  public boolean checkShake(){ //IF TOTAL NUMBER OF [changes between consecutive movement angles is greater than a threshhold] WITHIN A TIMEFRAME IS GREATER THAN THRESHOLD -> Shake detected
    shakeReset = false;    
    PVector diffs = new PVector(x - shakex, y - shakey);
    if(diffs.mag() > shakeMagThresh){ //add movevector angle to shakedir whenever puck is moved
      float currshakedir = limradians(diffs.heading());
      if(shakedir != -1){
        if(minangdiff(shakedir,currshakedir) > shakeAngThresh){
          shakeCounter += 1;
          shakems = millis() + shakeDecayPeriod;
        }
      }
      shakedir = currshakedir;
    }else{
      shakedir = -1;
      if(mspassed(shakems,shakeDecayPeriod)){
        resetShake();
      }
    }
    shakex = x;
    shakey = y;
    return shakeCounter >= shakeCounterThresh;
  }
  
  public void mouseRotate(float e){
    //baserotation = (e > 0)? baserotation + 10 : baserotation - 10;
    baserotation = baserotation + e*scrollmult;
    float rotationdelta = baserotation - prebaserotation;
    if(rotationdelta != 0){
      zoneRotate(rotationdelta);
      prebaserotation = baserotation;
    }
  }
  
  public void zoneRotate(float delta){
    if(currZone == 0){
      catrotation = limdegrees(catrotation + delta);
      selectCategory();
      showMenu();
    }else if(currZone == 1){
      float mult = pow(10,min(2,PApplet.parseInt(abs(delta)/4)));
      delta = delta*mult;
      if(selectComValue(PApplet.parseInt(delta))){
        valrotation = PApplet.parseInt(selectedvalue*0.36f);
      }
      
      showMenu();
    }else if(currZone == 2){
      if(MASTERPUCK){
        if(runzone.state == 3 || runzone.state == 4){
          MASTERrotation = min(290,max(250,limdegrees(MASTERrotation + delta)));
          selectMASTERMult();
          showMenu();
        }
      }
    }else if(currZone == 3){
      comrotation = limdegrees(comrotation + delta);
      selectCategoryComponent();
      showMenu();
    }else if(currZone == 4){
      float mult = pow(10,min(2,PApplet.parseInt(abs(delta)/4)));
      delta = delta*mult;
      if(selectComTimeValue(PApplet.parseInt(delta))){
        timerotation = PApplet.parseInt(selectedTvalue*0.36f);
      }
      showMenu();
    }else{
      if(circuitRun){
        staterotation = limdegrees(staterotation + delta);
        selectState();
        showMenu();
      }else{
        rotation = limdegrees(rotation + delta);
      }
    }
  }
  
  public void mouseMove(){
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
    updated = true;
  }
  
  public void showMenu(){
    if(!menushow){
      menushow = true;
      menuclock = 100;
    }else{
      menuclock = 90;
    }
  }
  
  public void hideMenu(){
    if(menuclock > 0){
      if(mspassed(menums,10)){
        menuclock--;
        menums = millis();
      }
    }else{
      menushow = false;
    }
  }
  
  public void selectState(){
    selectedstate = min(selectedComponent.noStates-1,PApplet.parseInt(map(staterotation,0,360,0,selectedComponent.noStates)));
  }
  
  public void selectMASTERMult(){
    selectedMASTER = PApplet.parseInt(map(MASTERrotation,250,290,-2,2));
    runzone.setmultiplier(selectedMASTER);
  }
  
  public void selectCategoryComponent(){
    Component prevCom = selectedComponent;
    selectedComponent = selectedCategory.cat.get( min(selectedCategory.cat.size()-1,PApplet.parseInt(map(comrotation,0,360,0,selectedCategory.cat.size()))) );
    if(!prevCom.equals(selectedComponent)){
      resetComponent();
      if(prevCom.terminals != selectedComponent.terminals){
        removeConnections();
      }
    }
  }
  
  public void selectCategory(){
    Component prevCom = selectedComponent;
    ComponentCategory prevCat = selectedCategory;
    selectedCategory = categories.get(min(catno-1,PApplet.parseInt(map(catrotation,0,360,0,catno))));
    if(!prevCat.equals(selectedCategory)){
      resetCategory();
    }
    if(prevCom.terminals != selectedComponent.terminals){
      removeConnections();
    }
  }
  
  public boolean selectComValue(int delta){
    if(!selectedComponent.valueChange){
      return false;
    }else{
      int valhi = selectedComponent.valHi, vallo = selectedComponent.valLo;
      int prehi = selectedComponent.preHi, prelo = selectedComponent.preLo;
      if(delta > 0){
        if(selectedvalue + delta > valhi){
          if(selectedprefix < prehi){
            selectedvalue = selectedvalue + delta - valhi;
            selectedprefix += 1;
          }else{
            selectedvalue = valhi;
          }
        }else{
          selectedvalue += delta;
        }
      }else{
        if(selectedvalue + delta < vallo){
          if(selectedprefix > prelo){
            selectedvalue = selectedvalue + delta + valhi;
            selectedprefix -= 1;
          }else{
            selectedvalue = vallo;
          }
        }else{
          selectedvalue += delta;
        }
      }
      updateValtext();
      return true;
    }
  }
  
  public void updateValtext(){
    valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
    if(selectedComponent.name.equals("Oscilloscope")){
      oscRange = selectedvalue * pow(1000,selectedprefix);
      if(puckGraph != null){
        puckGraph.setMaxMin(oscRange, valtext);
      }
    }
  }
  
  public boolean selectComTimeValue(int delta){
    if(!selectedComponent.timeChange){
      return false;
    }else{
      int valhi = selectedComponent.TvalHi, vallo = selectedComponent.TvalLo;
      int prehi = selectedComponent.TpreHi, prelo = selectedComponent.TpreLo;
      if(delta > 0){
        if(selectedTvalue + delta > valhi){
          if(selectedTprefix < prehi){
            selectedTvalue = selectedTvalue + delta - valhi;
            selectedTprefix += 1;
          }else{
            selectedTvalue = valhi;
          }
        }else{
          selectedTvalue += delta;
        }
      }else{
        if(selectedTvalue + delta < vallo){
          if(selectedTprefix > prelo){
            selectedTvalue = selectedTvalue + delta + valhi;
            selectedTprefix -= 1;
          }else{
            selectedTvalue = vallo;
          }
        }else{
          selectedTvalue += delta;
        }
      }
      updateTimetext();
      return true;
    }
  }
  
  public void updateTimetext(){
    timetext = selectedComponent.generateComponentTimeText(selectedTvalue, selectedTprefix);
  }
  
  public void resetComponent(){
    selectedvalue = selectedComponent.dValue;
    selectedprefix = selectedComponent.dPrefix;
    
    selectedTvalue = selectedComponent.dTValue;
    selectedTprefix = selectedComponent.dTPrefix;
    
    selectedstate = selectedComponent.dState;
    for(int e = 0; e < voltages.length; e++){
      voltages[e] = 0;
      currents[e] = 0;
    }
    valrotation = PApplet.parseInt(selectedvalue*0.36f);
    timerotation = PApplet.parseInt(selectedTvalue*0.36f);
    
    staterotation = 0;
    valtext = selectedComponent.generateComponentText(selectedvalue, selectedprefix);
    timetext = selectedComponent.generateComponentTimeText(selectedTvalue, selectedTprefix);
    removeGraph();
  }
  
  public void resetCategory(){
    selectedComponent = selectedCategory.cat.get(0);
    comrotation = 0;
    resetComponent();
  }
  
  public int checkZone(){
    int outz = -1;
    for(Zone thisz:zones){
      if(thisz.puckWithin(x,y)){
        if(circuitRun){
          if(thisz.id == 2){
            outz = thisz.id;
          }
        }else{
          outz = thisz.id;
        }
      }
    }
    return outz;
  }
  
  public void setid(){
    id = pucks.indexOf(this);
  }
  
  public void run(){
    setid();
    
    if(selected){
      mouseMove();
      if(!circuitRun){
        if(checkShake()){
          print("shook");
          resetShake();
          if(!removeConnections()){
            resetComponent();
          }
        }
      }
    }else{
      resetShake();
    }
    
    if(selectedComponent.name.equals("Voltmeter") || selectedComponent.name.equals("Oscilloscope")){ //VOLTMETER
      if(connectedWires[0] != null && connectedWires[1] != null){ 
        voltageAcross = connectedWires[0].voltage - connectedWires[1].voltage;
      }
    }
    
    if(selectedComponent.name.equals("Oscilloscope")){ //OSCILLOSCOPE - ADD GRAPH
      addGraph(new Graph(oscX,oscY,100,100,1,true));
    }
    
    if(menuclock > 90){
      menualpha = PApplet.parseInt(map(menuclock,100,90,0,255));
    }else if(menuclock < 10){
      menualpha = PApplet.parseInt(map(menuclock,0,10,0,255));
    }else{
      menualpha = 255;
    }
    
    if(updated){
      currZone = checkZone();
      if(currZone == 2 && runzone.ThePuck == null){
        runzone.ThePuck = this;
      }else if(currZone == -1){
        if(!circuitRun){
          menushow = false;
          menuclock = 0;
        }
      }
    }
    
    for(int i = 0; i < 3; i++){
      if(beginconnection.get(i) == 0 && connectclock.get(i) > 0){
        if(connectclock.get(i) > 0){
          connectclock.sub(i,5);
        }else{
          connectclock.set(i,0);
        }
      }
    }
  }
  
  //==========================================================
  //==================== CONNECTION STUFF ====================
  //==========================================================

  public boolean noConnections(){
    for(int w = 0; w < connectedWires.length; w++){
      if(connectedWires[w] != null){
        return false;
      }
    }
    return true;
  }
  
  public boolean removeConnections(){ //return false if nothing is removed
    if(!this.noConnections()){
      for(int w = 0; w < connectedWires.length; w++){
        Wire thiswire = connectedWires[w];
        if(thiswire != null){
          int puckind = thiswire.connectedPucks.indexOf(this);
          thiswire.connectedPucks.remove(this);
          thiswire.sides.remove(puckind);
          thiswire.checkDestroy();
          thiswire.update();
          connectedWires[w] = null;
        }
      }
      println("removed connections from " + id);
      return true;
    }
    return false;
  }
  
  public int readyConnectTo(Puck otherPuck){
    float angtopuck = atan2(otherPuck.y-y,otherPuck.x-x);
    float rotrad = radians(rotation);
    float combang = limradians(angtopuck - rotrad);
    int sendBack = 0;
    float offset = -PI/2;
    
    int terminals = selectedComponent.terminals;
    float connectAng = 2*PI/terminals;
    if(terminals == 3){
      offset += -2*PI/12;
    }
    for(int i = 0; i < terminals; i++){
      if(withinradians(combang, limradians(offset + i*connectAng), limradians(offset + (i+1)*connectAng))){
        if(connectedWires[i] != null){
          if(connectedWires[i].connectedPucks.contains(otherPuck)){
            beginconnection.set(i,0);
          }else{
            beginconnection.set(i,1);
          }
        }else{
          beginconnection.set(i,1);
        }
      }
    }
    
    for(int i = 0; i < 3; i++){
      if(beginconnection.get(i) == 1){
        if(connectclock.get(i) < 100){
          if(mspassed(connectms.get(i),5)){
            connectclock.add(i,1);
            connectms.set(i,millis());
          }
        }else{
          sendBack = i+1;
        }
      }
    }
    return sendBack;
  }
  
  public boolean addGraph(Graph newgraph){
    if(puckGraph == null){
      puckGraph = newgraph;
      graphs.add(newgraph);
      return true;
    }
    return false;
  }
  
  public boolean removeGraph(){
    if(puckGraph != null){
      graphs.remove(puckGraph);
      puckGraph = null;
      return true;
    }
    return false;
  }
  
  public void setShakeSettings(float shakeval){ //0 - SHAKE ALOT (UNSENSITIVE); 1 - SHAKE A LITTLE (SENSITIVE)
    shakeAngThresh = map(shakeval,0,1,PI-1,PI/4);
    shakeCounterThresh = PApplet.parseInt(map(shakeval,0,1,5,3));
    shakeMagThresh = map(shakeval,0,1,10,1);
    shakeDecayPeriod = PApplet.parseInt(map(shakeval,0,1,500,1500));
  }
  
  public void setScrollSettings(float scrollval){ //0 - SCROLL ALOT (UNSENSITIVE); 1 - SCROLL A LITTLE FOR MASSIVE ROTATION (SENSITIVE)
    scrollmult = (scrollval < 0.5f) ? map(scrollval, 0, 0.5f, 0.01f, 1) : map(scrollval, 0.5f, 1, 1, 100);
  }
  
  public void setPuckSize(float sizeval){ //0 - SCROLL ALOT (UNSENSITIVE); 1 - SCROLL A LITTLE FOR MASSIVE ROTATION (SENSITIVE)
    this.size = (sizeval < 0.5f) ? map(sizeval, 0, 0.5f, height/16, height/8) : map(sizeval, 0.5f, 1, height/8, height/4);
  }
  
  public void addError(int type){
    errors.append(type);
  }
  
  public void hideError(){
    errors.clear();
  }
  
}

public void connectPucks(Puck puckA, Puck puckB){
  int A = puckA.readyConnectTo(puckB);
  int B = puckB.readyConnectTo(puckA);
  
  if(A != 0 && B != 0){
    if(puckA.connectedWires[A-1] == null && puckB.connectedWires[B-1] == null){
      createWire(puckA, A, puckB, B);
    }else if(puckA.connectedWires[A-1] == null){
      addToWire(puckA, A, puckB.connectedWires[B-1]);
    }else if(puckB.connectedWires[B-1] == null){
      addToWire(puckB, B, puckA.connectedWires[A-1]);
    }else{
      combineWires(puckA.connectedWires[A-1], puckB.connectedWires[B-1]);
    }
    
    puckA.beginconnection.set(A-1,0);
    puckB.beginconnection.set(B-1,0);
  }else{
    updated = true;
  }
}

public void checkAuras(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    for(int i = 0; i < 3; i++){
      thispuck.beginconnection.set(i,0);
    }
  }
  updated = false;
  
  if(allpucks.size() > 1){
    for(int p1 = 0; p1 < allpucks.size() - 1; p1++){
      for(int p2 = p1 + 1; p2 < allpucks.size(); p2++){
        Puck thispuck = allpucks.get(p1);
        Puck thatpuck = allpucks.get(p2);
        if(thispuck.currZone == -1 && thatpuck.currZone == -1){
          if(circleincircle(thispuck.x,thispuck.y,thispuck.size+thispuck.aurasize,thatpuck.x,thatpuck.y,thatpuck.size+thatpuck.aurasize)){
            connectPucks(thispuck, thatpuck);
          }
        }
      }
    }
  }
}

public void setAllPuckInformationZero(){
  for(Puck tp:pucks){
    for(int e = 0; e < tp.voltages.length; e++){
      tp.voltages[e] = 0;
      tp.currents[e] = 0;
    }
  }
}

public void resetAllPuckGraphs(){
  for(Puck tp:pucks){
    if(tp.puckGraph != null){
      tp.puckGraph.resetValues();
    }
  }
}

public void updateAllPuckGraphs(int timeelapsed){
  for(Puck tp:pucks){
    if(tp.puckGraph != null){
      if(tp.puckGraph.OSCILLOSCOPE){
        tp.puckGraph.addValue(tp.voltageAcross);
      }else{
        tp.puckGraph.addValue(tp.currents[0]);
      }
    }
  }
}

public void hidePuckErrors(){
  for(Puck tp:pucks){
    tp.hideError();
  }
}
public void drawBackground(){
  if(circuitRun){
    background(50);
  }else if(removemode){
    background(100,0,0);
  }else if(graphmode){
    background(0,0,100);
  }else{
    background(0);
  }
}

public void showSettingsPanel(){
  fill(0);
  stroke(255);
  strokeWeight(3);
  rect(width/2,height/2,width*0.8f,height*0.8f);  
  
  fill(255);
  textSize(20);
  textAlign(CENTER);
  text("Settings", width/2, height*0.15f);
  
  textSize(16);
  textAlign(LEFT, CENTER);
  text("Scroll Sensitivity", width*0.15f,height*0.2f);
  
  text("Shake Sensitivity", width*0.15f,height*0.3f);
  
  text("Disc Size", width*0.15f,height*0.4f);
  
  //text("Disc Rotation", width*0.15, height*0.5); //segmented, natural 
  
  //stepsize -> steps of 1, 10, 100, 
  
  
  textAlign(CENTER);
  text("Save", width/2, height*0.85f);
  
  textSize(12);
  for(Slider thisslider:sliders){
    thisslider.display();
  }
  
  textSize(12);
}
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
  
  public void updateVoltage(float voltage){
    this.voltage = voltage; 
  }
  
  public void showVoltages(){
    showVoltage = true;
  }
  
  public void hideVoltages(){
    showVoltage = false;
  }
  
  public void display(){
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
        //text(sides.get(l/2),x,y);
      }
      noStroke();
      fill(255);
      ellipse(x,y,size,size);
    }else{
      stroke(255);
      strokeWeight(2);
      noFill();
      bezier(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y, lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
      //stroke(255,102,0,128);
      //line(lines.get(0).x, lines.get(0).y, lines.get(1).x, lines.get(1).y);
      //line(lines.get(3).x, lines.get(3).y, lines.get(2).x, lines.get(2).y);
    }
    //noStroke();
    //fill(255);
    //if(pointincircle(mouseX,mouseY,x,y,size)){
    //  ellipse(x,y,size*1.5,size*1.5);
    //}else{
    //  ellipse(x,y,size,size);
    //}
    
   
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
      line(x,y,x,y+puckSize*0.2f);
      line(x-puckSize*0.15f,y+puckSize*0.2f,x+puckSize*0.15f,y+puckSize*0.2f);
      line(x-puckSize*0.1f,y+puckSize*0.25f,x+puckSize*0.1f,y+puckSize*0.25f);
      line(x-puckSize*0.05f,y+puckSize*0.30f,x+puckSize*0.05f,y+puckSize*0.30f);
    }
    
    if(wireGraph != null){
      wireGraph.setAnchor(x,y);
    }
  }
  
  public void drawCurrents(float x, float y){
    //text(connectedPucks.size(),x+50,y - 10);
    //text(sides.size(),x+50,y);
    //text(lines.size(),x+50,y + 10);
    float current = 0;
    if(connectedPucks.size() > 2){
      for(int l = 0; l < lines.size(); l += 2){
        Puck thispuck = connectedPucks.get(l/2);
        PVector thisanch = lines.get(l);
        PVector thiscont = lines.get(l+1);
        
        if(thispuck.selectedCategory.name.equals("Active Components")){
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
      if(thispuck.selectedCategory.name.equals("Active Components")){
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
  
  public void matchCurrentCounters(){
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
  public void update(){
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
      lulavg.div(4.3f);
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
        x = bezierPoint(lines.get(0).x, lines.get(1).x, lines.get(3).x, lines.get(2).x, 0.5f);
        y = bezierPoint(lines.get(0).y, lines.get(1).y, lines.get(3).y, lines.get(2).y, 0.5f);
      }
    }
  }
  
  public void run(){
    setid();
    if(updated){
      update();
    }
  }
  
  public void setid(){
    id = wires.indexOf(this);
  }
  
  public void checkDestroy(){
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
  
  public void moveElectrons(int index, float ax, float ay, float bx, float by, float cx, float cy, float dx, float dy, float current, float density){
    float wireLength = bezierLength(ax,ay,bx,by,cx,cy,dx,dy,0.01f);
    int electronNo = max(1,PApplet.parseInt(wireLength/density));
    float newcurramount = currentCounter.get(index) + 500*sigmoid(current*circuitSimMultiplier);
    newcurramount = (newcurramount < 0) ? newcurramount + 1000 : newcurramount;
    currentCounter.set(index, newcurramount % 1000);
    fill(255,255,0);
    noStroke();
    for(int i = 0; i < electronNo; i++){
      float percentMoved = PApplet.parseFloat(i)/PApplet.parseFloat(electronNo) + (currentCounter.get(index)/(PApplet.parseFloat(1000*electronNo)));

      float x = bezierPoint(ax, bx, cx, dx, percentMoved);
      float y = bezierPoint(ay, by, cy, dy, percentMoved);
      ellipse(x,y,10,10);
    }
  }
  
  public boolean addGraph(Graph newgraph){
    if(wireGraph == null){
      wireGraph = newgraph;
      graphs.add(newgraph);
      return true;
    }
    return false;
  }
  
  public boolean removeGraph(){
    if(wireGraph != null){
      graphs.remove(wireGraph);
      wireGraph = null;
      return true;
    }
    return false;
  }
}

public void addToWire(Puck puckA, int A, Wire thiswire){
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

public void combineWires(Wire wireA, Wire wireB){
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

public void createWire(Puck puckA, int A, Puck puckB, int B){
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

public void hideWireVoltages(){
  for(Wire tw:wires){
    tw.hideVoltages();
  }
}

public void showWireVoltages(){
  for(Wire tw:wires){
    tw.showVoltages();
  }
}

public void setWireVoltagesZero(){
  for(Wire tw:wires){
    tw.voltage = 0;
  }
}

public void resetAllWireGraphs(){
  for(Wire tw:wires){
    if(tw.wireGraph != null){
      tw.wireGraph.resetValues();
    }
  }
}

public void updateAllWireGraphs(int timeelapsed){
  for(Wire tw:wires){
    if(tw.wireGraph != null){
      tw.wireGraph.addValue(tw.voltage);
    }
  }
  
}
class Zone{
  int id;
  String label;
  int type; //square - 0;circle - 1
  float x, y, w, h;
  Icon zoneicon;
  
  Zone(int id, String label, int type, float x, float y, float w, float h, Icon zoneicon){
    this.id = id;
    this.type = type;
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.zoneicon = zoneicon;
  }
  
  public void display(int fcolor, boolean fok, int scolor, boolean sok){
    if(fok){
      fill(fcolor);
    }else{
      noFill();
    }
    if(sok){
      stroke(scolor);
      strokeWeight(1);
    }else{
      noStroke();
    }
    if(type == 0){
      rectMode(CENTER);
      rect(x, y, w, h);
      if(zoneicon != null){
        zoneicon.display(x,y,min(w,h)/3,true,color(255),color(100),height/160);
      }
    }else if(type == 1){
      ellipse(x,y,w,h);
    }
    
  }
  
  public boolean puckWithin(float px, float py){
    if(type == 0){
      return pointinrect(px, py, x, y, w, h);
    }else if(type == 1){
      return pointincircle(px, py, x, y, h);
    }else{
      return false;
    }
  }
}

class Runzone extends Zone{
  int zoneclock, zoneanims, zoneanidur = 100;
  int zonebarclock, zonebanims, zonebanidur = 15;
  int state; //0 - idle, 1 - setting MASTERPUCK, 2 - ready with MASTERPUCK, 3 - turning with MASTERPUCK
  float sliderlength;
  Puck ThePuck = null;
  int circuitSimTimer, circuitSimTimePeriod = 100;
  float circuitSimStep = 0.1f; //seconds
  
  
  Runzone(int id, String label, int type, float x, float y, float w, float h, Icon zoneicon){
    super(id, label, type, x, y, w, h, zoneicon);
    this.zoneanims = millis();
    this.zoneclock = 0;
    this.zonebanims = millis();
    this.zonebarclock = 0;
    this.state = 0;
    this.sliderlength = w;
  }
  
  public void run(){
    switch(state){
      case 0:{
        if(ThePuck == null){
          if(zonebarclock > 0){
            if(mspassed(zonebanims,5)){
              zonebarclock--;
              zonebanims = millis();
            }
          }else{
            if(zoneclock > 0){
              if(mspassed(zoneanims,5)){
                zoneclock--;
                zoneanims = millis();
              }
            }
          }
        }else{
          state = 1;
        }
        break;
      }
      case 1:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(zoneclock < zoneanidur){
            if(mspassed(zoneanims,5)){
              zoneclock++;
              zoneanims = millis();
            }
          }else{
            state = 2;
            ThePuck.MASTERPUCK = true;
          }
        }else{
          reset();
        }
        break;
      }
      case 2:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(zonebarclock < zonebanidur){
            if(mspassed(zonebanims,5)){
              zonebarclock++;
              zonebanims = millis();
            }
          }else{
            zonebarclock = zonebanidur;
            type = 2;
            state = 3;
          }
          
          ThePuck.removeConnections();
          //ThePuck.removeGraph();
        }else{
          reset();
        }
        break;
      }
      case 3:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(ThePuck.x < x-sliderlength/2){
            state = 4;
          }
          circuitRun = false;
          if(circuitChecked){
            circuitChecked = false;
            oscY = height*0.67f;
            updateOSCgraphpos(oscX,oscY);
            elapsedTime = 0;
            hideWireVoltages();
            hidePuckErrors();
          }
        }else{
          reset();
        }
        break;
        
      }
      
      case 4:{
        if(puckWithin(ThePuck.x, ThePuck.y)){
          if(ThePuck.x > x-sliderlength/2){
            state = 3;
          }
          if(!circuitChecked){
            circuitChecked = true;
            if(checkCircuit()){
              circuitRun = true;
              oscY = height*0.87f;
              updateOSCgraphpos(oscX,oscY);
              setWireVoltagesZero();
              //setPuckInformationZero();
              resetAllPuckGraphs();
              circuitSimTimer = millis();
              NGCircuitRT(circuitSimStep, true);//first iteration
              elapsedTime += circuitSimStep;
            }else{
              circuitRun = false;
            }
          }
          if(circuitRun){  //RUN THE SIMULATION
            if(mspassed(circuitSimTimer,circuitSimTimePeriod)){
              NGCircuitRT(circuitSimStep, false);
              elapsedTime += circuitSimStep;
              showWireVoltages();
              updateAllPuckGraphs(circuitSimTimer);
              updateAllWireGraphs(circuitSimTimer);
              circuitSimTimePeriod = 100 - ((millis() - circuitSimTimer) - circuitSimTimePeriod); //DIFFERENCE IN TIME --> CORRECT NEXT ITERATION
              circuitSimTimer = millis();
            }
          }
          
        }else{
          reset();
        }
        break;
        
      }
      
      default:
        state = 0;
        break;
    }
  }
  
  public boolean puckWithin(float px, float py){
    if(type == 2){
      return pointincircle(px, py, x, y, h) || pointincircle(px, py, x-sliderlength, y, h) || pointinrect(px, py, x-sliderlength/2,y,sliderlength,w);
    }else{
      return super.puckWithin(px,py);
    }
  }
  
  public void reset(){
    circuitRun = false;
    if(ThePuck != null){
      ThePuck.MASTERrotation = 270;
      ThePuck.selectedMASTER = 0;
      ThePuck.MASTERPUCK = false;
      ThePuck = null;
    }
    hidePuckErrors();
    oscY = height*0.67f;
    updateOSCgraphpos(oscX,oscY);
    circuitSimMultiplier = 1;
    circuitSimStep = 0.1f;
    circuitSimTimePeriod = 100;
    state = 0;
    type = 1;
  }
  
  public void display(int fcolor, boolean fok, int scolor, boolean sok){
    if(state == 0){
      if(zonebarclock > 0){
        float anix = map(zonebarclock, 0, zonebanidur, 0, sliderlength);
        float anialph = map(zonebarclock, 0, zonebanidur, 255, 0);
        noStroke();
        fill(fcolor, anialph);
        rectMode(CENTER);
        rect(x-anix/2,y,anix,w+5);
        
        stroke(255);
        strokeWeight(5);
        line(x-anix,y+w/2+2.5f,x,y+w/2+2.5f);
        line(x-anix,y-w/2-2.5f,x,y-w/2-2.5f);
        arc(x,y,w+5,w+5,-PI/2,PI/2);
        arc(x-anix,y,w+5,w+5,PI/2,3*PI/2);
      }else{
        if(zoneclock > 0){
          float aniang = map(zoneclock, 0, zoneanidur, 0, 2*PI);
          stroke(255);
          strokeWeight(5);
          noFill();
          arc(x,y,w+5,w+5,-PI/2,-PI/2+aniang);
        }
        super.display(fcolor, fok, scolor, sok);
      }
    }else if(state == 1){
      float aniang = map(zoneclock, 0, zoneanidur, 0, 2*PI);
      stroke(255);
      strokeWeight(5);
      noFill();
      arc(x,y,w+5,w+5,-PI/2,-PI/2+aniang);
      super.display(fcolor, fok, scolor, sok);
    }else if(state == 2){
      float anix = map(zonebarclock, 0, zonebanidur, 0, sliderlength);
      float anialph = map(zonebarclock, 0, zonebanidur, 255, 0);
      noStroke();
      fill(fcolor, anialph);
      rectMode(CENTER);
      rect(x-anix/2,y,anix,w+5);
      
      stroke(255);
      strokeWeight(5);
      line(x-anix,y+w/2+2.5f,x,y+w/2+2.5f);
      line(x-anix,y-w/2-2.5f,x,y-w/2-2.5f);
      arc(x,y,w+5,w+5,-PI/2,PI/2);
      arc(x-anix,y,w+5,w+5,PI/2,3*PI/2);
    }else if(state == 3 || state == 4){
      noStroke();
      if(state == 4){
        fill(fcolor);
      }else{
        fill(0);
      }
      rectMode(CENTER);
      rect(x-sliderlength/2,y,sliderlength,w);
      
      stroke(255);
      strokeWeight(1);
      line(x-sliderlength/2, y+w/2, x-sliderlength/2, y-w/2);
      
      strokeWeight(5);
      line(x-sliderlength,y+w/2+2.5f,x,y+w/2+2.5f);
      line(x-sliderlength,y-w/2-2.5f,x,y-w/2-2.5f);
      arc(x,y,w+5,w+5,-PI/2,PI/2);
      arc(x-sliderlength,y,w+5,w+5,PI/2,3*PI/2);
    }
    //super.display(fcolor, fok, scolor, sok);
    
  }
  
  public void displayBar(float menualpha, float rad, int chosenvalue){
    stroke(menualpha);
    strokeWeight(5);
    noFill();
    pushMatrix();
    translate(x-sliderlength,y);
    arc(0,0,w+rad,w+rad,PI*7/8,PI*9/8);
    arc(0,0,w+rad*4,w+rad*4,PI*7/8,PI*9/8);
    pushMatrix();
    rotate(-PI/8);
    arc(-w/2-rad*5/4,0,rad*3/2,rad*3/2,0,PI);
    rotate(PI*2/8);
    arc(-w/2-rad*5/4,0,rad*3/2,rad*3/2,PI,2*PI);
    popMatrix();
    float addangle = chosenvalue * PI/16;
    rotate(addangle);
    fill(menualpha);
    noStroke();
    ellipse(-w/2-rad*5/4,0,rad*3/2,rad*3/2);
    
    popMatrix();
  }
  
  public void setmultiplier(int chosenvalue){
    circuitSimStep = 0.1f*pow(2,chosenvalue);
    circuitSimMultiplier = pow(2,chosenvalue);
  }
  
}


public void drawZones(){
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
  public void settings() {  size(1200,800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "v2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
