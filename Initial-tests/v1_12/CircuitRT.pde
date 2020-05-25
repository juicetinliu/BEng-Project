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
          if(thiscomp.id == 6){ //DIODE
            String newline = "R" + IDcode + " ";
            newline += chkpuck.connectedWires[0].id + " " + chkpuck.connectedWires[0].id + "D" + IDcode + " 1"; //ADD SMALL RESISTOR IN SERIES WITH DIODE
            lines.append(newline);
            
            thisline += chkpuck.connectedWires[0].id + "D" + IDcode + " ";
          }else{
            thisline += chkpuck.connectedWires[0].id + " "; //ADD FIRST NODE
          }
          
          String currNode = "";
          if(thiscomp.id == 5){ //VOLTAGE SOURCE DOESN'T NEED EXTRA CURRENT MEASURE
            thisline += chkpuck.connectedWires[1].id + " "; //ADD SECOND NODE
          }else{
            currNode = chkpuck.connectedWires[1].id + IDcode; //CREATE SECOND NODE FOR CURRENT MEASURE
            thisline += currNode + " "; //ADD SECOND NODE
          }
          
          //===== ADD INFORMATION =====
          if(thiscomp.id == 5){ //VOLTAGE SOURCES
            if(firstiteration){
              thisline += "PULSE(0 " + val;
            }else{
              thisline += "PULSE(" + val + " " + val;
            }
            thisline += " 0s 1fs 1fs)"; //ADD VALUE OF VOLTAGE SOURCE
          
          }else{
            if(thiscomp.id == 6){ //ADD DIODE MODEL
              thisline += "diode1";
            }else{
              thisline += val; //ADD VALUE OF COMPONENT
            }
            
            if(thiscomp.id == 4){ //INDUCTOR
              thisline += " ic=" + chkpuck.currents[0]; //ADD INITIAL CURRENT
            }else if(thiscomp.id == 2){ //CAPACITOR
              thisline += " ic=" + chkpuck.voltages[0]; //ADD INITIAL VOLTAGE
            }else if(thiscomp.id == 6){ //DIODE
              thisline += " ic=" + chkpuck.voltages[0]; //ADD INITIAL VOLTAGE
            }
          }
          
          //===== ADD CURRENT SENSING SOURCE =====
          if(thiscomp.id != 5){ //VOLTAGE SOURCE DOESN'T NEED EXTRA CURRENT MEASURE
            String nxtline = "";    //CREATE NEW LINE
            nxtline += "V" + IDcode + " "; //CURRENT MEASURE VOLTAGE SOURCE
            nxtline += currNode + " " + chkpuck.connectedWires[1].id + " 0"; //0V VOLTAGE SOURCE IN SERIES TO MEASURE CURRENT
            lines.append(nxtline);
          }
          lines.append(thisline);
          
        }else if(thiscomp.terminals == 3){ //FOR THREE TERMINAL COMPONENTS
          if(thiscomp.id == 7){ //BJT
            thisline += IDcode + " "; //ADD NAME AND ID
          
            //===== ADD NODES =====
            String colI = chkpuck.connectedWires[0].id + IDcode; //CREATING CURRENT
            String basI = chkpuck.connectedWires[2].id + IDcode; //SENSING
            String emiI = chkpuck.connectedWires[1].id + IDcode; //NODES
            
            thisline += colI + " "; //ADD COLLECTOR NODE
            thisline += basI + " "; //ADD BASE NODE
            thisline += emiI + " "; //ADD EMITTER NODE
            if(chkpuck.selectedtype == 0){
              thisline += "QMODN"; //ADD NPN BJT MODEL
            }else{
              thisline += "QMODP"; //ADD PNP BJT MODEL
            }
            thisline += " ic=" + chkpuck.voltages[0] + ", " + chkpuck.voltages[1]; //ADD INITIAL VOLTAGES (VBE, VCE)
            
            String colVs = "V" + IDcode + "C ";
            String basVs = "V" + IDcode + "B ";
            String emiVs = "V" + IDcode + "E ";
            colVs += colI + " " + chkpuck.connectedWires[0].id + " 0";
            basVs += basI + " " + chkpuck.connectedWires[2].id + " 0";
            emiVs += emiI + " " + chkpuck.connectedWires[1].id + " 0";
            
            lines.append(thisline);
            lines.append(colVs);
            lines.append(basVs);
            lines.append(emiVs);
          }
          
        }
      }
    }
  }
  
  
  lines.append(".model switch1 sw vt=1");
  lines.append(".model diode1 D(Ron=0.1 Roff=1Meg Vfwd=0.7)");
  lines.append(".model QMODN NPN level=1");
  lines.append(".model QMODP PNP level=1");
  
  //lines.append(".MODEL diode1 D(IS=4.352E-9 N=1.906 BV=110 IBV=0.0001 RS=0.6458 CJO=7.048E-13 VJ=0.869 M=0.03 FC=0.5 TT=3.48E-9 ");
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
      if(thiscomp.id != 0){
        if(thiscomp.id == 5){
          printline += " i(V" + chkpuck.id + ")[k]";
        }else if(thiscomp.id == 7){
          String idcode = thiscomp.NGname + chkpuck.id;
          printline += " i(V" + idcode + "C)[k]";
          printline += " i(V" + idcode + "B)[k]";
          printline += " i(V" + idcode + "E)[k]";
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
      if(thiscomp.id != 0){
        if(thiscomp.id == 7){
          String line = output.get(lineptr);
          String[] list = split(line, " = ");
          thispuck.currents[1] = float(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[2] = float(list[1].trim());
          lineptr--;
          line = output.get(lineptr);
          list = split(line, " = ");
          thispuck.currents[0] = float(list[1].trim());
          lineptr--;
        }else{
          String line = output.get(lineptr);
          String[] list = split(line, " = ");
          thispuck.currents[0] = float(list[1].trim());
          lineptr--;
          if(thiscomp.id == 2){ //CAPACITOR VOLTAGE
            thispuck.voltages[0] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
          }else if(thiscomp.id == 6){ //DIODE VOLTAGE
            thispuck.voltages[0] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
            //lineptr--;
          }
        }
      } 
    }
  }
  
}
