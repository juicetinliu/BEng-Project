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
    String thisline = "";
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      
      if(thiscomp.id == 3){ //switch
        thisline += thiscomp.NGname + chkpuck.id + " ";
        for(int ck = 0; ck < thiscomp.terminals; ck++){
          thisline += chkpuck.connectedWires[ck].id + " ";
        }
        
        int swvplus = wires.size() + chkpuck.id;
        String nxtline = "";
        nxtline += "Vs" + chkpuck.id + " " + swvplus + " 0 ";
        
        thisline += swvplus + " 0 switch1 ";
        if(chkpuck.selectedstate == 0){
          thisline += "OFF";
          nxtline += "0";
        }else{
          thisline += "ON";
          nxtline += "2";
        }
        lines.append(thisline);
        lines.append(nxtline);
        
      }else if(thiscomp.id == 0){
        //nothing for wire 
        
      }else if(thiscomp.id == 6){ //diode
        thisline += thiscomp.NGname + chkpuck.id + " ";
        for(int ck = thiscomp.terminals - 1; ck >= 0; ck--){
          thisline += chkpuck.connectedWires[ck].id + " ";
        }
        thisline += "diode1";
        lines.append(thisline);
        
      }else if(thiscomp.id == 4){ //inductor
        thisline += thiscomp.NGname + chkpuck.id + " ";
        thisline += chkpuck.connectedWires[0].id + " ";
        
        String indmes = chkpuck.connectedWires[1].id + "i";
        thisline += indmes + " ";
        
        thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
        thisline += " ic=" + chkpuck.extraInformation[0];
        
        String nxtline = "";
        nxtline += "Vl" + chkpuck.id + " ";
        nxtline += indmes + " " + chkpuck.connectedWires[1].id + " 0";
        
        lines.append(thisline);
        lines.append(nxtline);
        
      }else{
        thisline += thiscomp.NGname + chkpuck.id + " ";
        for(int ck = 0; ck < thiscomp.terminals; ck++){
          thisline += chkpuck.connectedWires[ck].id + " ";
        }
        String val = chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
        if(thiscomp.id == 5){ //PULSE(0 V 0s 1fs 1fs)
          if(firstiteration){
            thisline += "PULSE( 0 " + val;
          }else{
            thisline += "PULSE(" + val + " " + val;
          }
          thisline += " 0s 1fs 1fs)";
        }else{
          thisline += val;
        }
        
        //if(thiscomp.id == 4){ //inductor
        //  //thisline += " ic=" + chkpuck.extraInformation[0];
        //}else 
        if(thiscomp.id == 2){ //capacitor
          thisline += " ic=" + chkpuck.extraInformation[0];
        }
        lines.append(thisline);
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
  
  for(Puck chkpuck:pucks){
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      if(thiscomp.id == 4){ //inductor
        printline += " i(Vl" + chkpuck.id + ")[k]";
      }
    }
  }
  
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
      if(thiscomp.id == 4){ //inductor
        String line = output.get(lineptr);
        String[] list = split(line, " = ");
        thispuck.extraInformation[0] = float(list[1].trim());
        lineptr--;
      }else if(thiscomp.id == 2){ //capacitor
        thispuck.extraInformation[0] = thispuck.connectedWires[0].voltage - thispuck.connectedWires[1].voltage;
        //lineptr--;
      }
    }
  }
  
}
