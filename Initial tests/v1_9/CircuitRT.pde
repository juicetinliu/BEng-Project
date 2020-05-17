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

boolean checkCircuit(){ 
  for(int p = 0; p < pucks.size(); p++){
    Puck checkpuck = pucks.get(p);
    if(!checkpuck.MASTERPUCK){
      Component thiscomp = checkpuck.selectedComponent;
      for(int ck = 0; ck < thiscomp.terminals; ck++){ 
        if(checkpuck.connectedWires[ck] == null){ //all pucks must have connections to nodes
          return false;
        }
      }
      if(thiscomp.id == 0){ //no pucks can be wires
        return false;
      }
    }   
  }
  return true;
}

void NGCircuitRT(float RTStepSize){
  StringList lines = new StringList();
  
  lines.append("HEHE"); //TITLE
  
  String icline = ".ic";
  for(int w = 1; w < wires.size(); w++){
    Wire tw = wires.get(w);
    icline += " v(" + tw.id + ")=" + tw.voltage;
  }
  lines.append(icline); //.ic v(1)=.......
  
  for(Puck chkpuck:pucks){
    String thisline = "";
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      
      String IDcode = thiscomp.NGname + chkpuck.id; //NAME AND ID
      
      if(thiscomp.id == 3){ //switch
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
      }else if(thiscomp.id != 0){
        if(thiscomp.terminals == 2){ //FOR TWO TERMINAL COMPONENTS
          String val = chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix); //VALUE OF PUCK COMPONENT
          thisline += IDcode + " "; //ADD NAME AND ID
          
          //===== ADD NODES =====
          thisline += chkpuck.connectedWires[0].id + " "; //ADD FIRST NODE
          
          String currNode = chkpuck.connectedWires[1].id + IDcode; //CREATE SECOND NODE FOR CURRENT MEASURE
          thisline += currNode + " "; //ADD SECOND NODE
          
          //===== ADD INFORMATION =====
          if(thiscomp.id == 5){ //VOLTAGE SOURCES
            thisline += "PULSE(" + val + " " + val;
            thisline += " 0s 1fs 1fs)"; //ADD VALUE OF VOLTAGE SOURCE
          
          }else{
            if(thiscomp.id == 6){ //DIODE MODEL
              thisline += "diode1";
            }else{
              thisline += val; //ADD VALUE OF COMPONENT
            }
            
            if(thiscomp.id == 4){ //INDUCTOR
              thisline += " ic=" + chkpuck.extraInformation[0]; //ADD INITIAL CURRENT
            }else if(thiscomp.id == 2){ //CAPACITOR
              thisline += " ic=" + chkpuck.extraInformation[1]; //ADD INITIAL VOLTAGE
            }
          }
          
          //===== ADD CURRENT SENSING SOURCE =====
          String nxtline = "";    //CREATE NEW LINE
          nxtline += "V" + IDcode + " "; //VOLTAGE SOURCE
          nxtline += currNode + " " + chkpuck.connectedWires[1].id + " 0"; //0V VOLTAGE SOURCE IN SERIES TO MEASURE CURRENT
          
          
          lines.append(thisline);
          lines.append(nxtline);
        }
      }
    }
  }
  
  
  lines.append(".model switch1 sw vt=1");
  lines.append(".model diode1 D(Ron=0.1 Roff=1Meg Vfwd=0.7)");
  
  //lines.append(".option rshunt = 1.0e12");
  //lines.append(".option rseries = 1.0e-4");
  
  
  //.control
  //tran <step> <duration> uic
  //let k = length(time) - 1
  //print time[k] v(1)[k] v(2)[k]
  //.endc
  //.end
  
  lines.append(".control");
  
  String tranline = "tran ";
  
  //float RTStepSize = 0.1;
  
  tranline += RTStepSize/10 + "s ";
  tranline += RTStepSize + "s uic";
  lines.append(tranline);
  
  lines.append("let k = length(time) - 1");
  
  String printline = "print time[k]";
  
  //===== PRINT CURRENTS =====
  for(Puck chkpuck:pucks){
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      if(thiscomp.id != 0){ //inductor
        printline += " i(V" + thiscomp.NGname + chkpuck.id + ")[k]";
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
  
  for(Wire tw:wires){
    tw.showVoltages();
  }
}

void NGparseOutputRT(StringList output){
  int outlen = output.size();
  
  for(int o = outlen - wires.size() + 1; o < outlen; o++){
    String line = output.get(o);
    String[] list = split(line, " = ");
    wires.get(o + wires.size() - outlen).updateVoltage(float(list[1].trim()));
  }
  
  int lineptr = outlen - wires.size();
  for(int p = pucks.size() - 1; p >= 0; p--){
    Puck thispuck = pucks.get(p);
    if(!thispuck.MASTERPUCK){
      Component thiscomp = thispuck.selectedComponent;
      if(thiscomp.id != 0){
        String line = output.get(lineptr);
        String[] list = split(line, " = ");
        thispuck.extraInformation[0] = float(list[1].trim());
        lineptr--;
        if(thiscomp.id == 2){ //capacitor
          thispuck.extraInformation[1] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
          //lineptr--;
        }
      } 
    }
  }
  
}
