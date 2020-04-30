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
      if(thiscomp.id != 0 || thiscomp.id != 3){
        thisline += thiscomp.NGname + chkpuck.id + " ";
        for(int ck = 0; ck < thiscomp.terminals; ck++){
          thisline += chkpuck.connectedWires[ck].id + " ";
        }
        if(thiscomp.id == 5){ //PULSE(0 V 0s 1fs 1fs)
          thisline += "PULSE(0 " + chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
          thisline += " 0s 1fs 1fs)";
        }else{
          thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
        }
        lines.append(thisline);
      }
    }
  }
  
  
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
}
