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

boolean checkCircuit(){
  boolean noError = true;
  for(int p = 0; p < pucks.size(); p++){
    Puck checkpuck = pucks.get(p);
    if(!checkpuck.MASTERPUCK){
      Component thiscomp = checkpuck.selectedComponent;
      for(int ck = 0; ck < thiscomp.terminals; ck++){ 
        if(checkpuck.connectedWires[ck] == null){ //all pucks must have connections to nodes
          checkpuck.addError(ck);
          noError = false;
        }
      }
      //if(thiscomp.name.equals("Wire")){ //no pucks can be wires
      //  checkpuck.addError(404);
      //  noError = false;
      //}
      if(thiscomp.name.equals("Voltmeter") || thiscomp.name.equals("Oscilloscope")){ //
        for(int ck = 0; ck < thiscomp.terminals; ck++){
          if(checkpuck.connectedWires[ck] != null){
            Wire thiswire = checkpuck.connectedWires[ck];
            int compcounter = 0;
            for(Puck tp:thiswire.connectedPucks){
              if(!tp.selectedComponent.name.equals("Voltmeter") && !tp.selectedComponent.name.equals("Oscilloscope")){
                compcounter++;
              }
            }
            if(compcounter <= 1){ //all pucks must have connections to nodes
              checkpuck.addError(404);
              noError = false;
            }
          }
        }
      }
    }   
  }
  return noError;
  
  
}

void NGCircuitRT(float RTStepSize, boolean firstiteration){
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
              float newtvalue = 4*float(chkpuck.selectedTvalue);
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

void NGparseOutputRT(StringList output){
  int outlen = output.size();
  
  for(int o = outlen - wires.size() + 1; o < outlen; o++){ //FIRST PARSE NODAL VOLTAGES
    String line = output.get(o);
    String[] list = split(line, " = ");
    wires.get(o + wires.size() - outlen).updateVoltage(float(list[1].trim()));
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
          thispuck.currents[2] = float(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[1] = float(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[0] = float(list[1].trim());
          lineptr--;
        }else if(thiscomp.name.equals("Current Source")){
          thispuck.currents[0] = thispuck.selectedvalue * pow(1000, thispuck.selectedprefix);
        }else{
          String line = output.get(lineptr);
          String[] list = split(line, " = ");
          thispuck.currents[0] = float(list[1].trim());
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
