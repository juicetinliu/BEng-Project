StringList output = new StringList();
StringList errors = new StringList();

//checked -> Disable component/value change; rotation only changes state of component (Switch ON/OFF);
//create copy of pucks (once puck is visited, remove from pucks)
//no voltage source -> error
//wire -> merge both sides
//switch -> OFF:ignore component; ON:merge nodes on both sides (act as wire)

//0, "Wire"
//1, "Resistor"
//2, "Capacitor"
//3, "Switch"
//4, "Inductor"
//5, "VoltageSource"

boolean NEWcheckCircuit(){
  checked = true;
  ArrayList<Puck> puckcopy = new ArrayList<Puck>();
  pucks.addAll(puckcopy);
  
  StringList lines = new StringList();
  
  lines.append("HEHE"); //TITLE
  
  Boolean voltagesource = false;
  while(puckcopy.size() > 0){
    Puck checkpuck = puckcopy.get(0);
    if(checkpuck.MASTERPUCK){
      puckcopy.remove(checkpuck);
    }else{
      Component thiscomp = checkpuck.selectedComponent;
      if(thiscomp.id == 0){ //if wire
      }
      for(int ck = 0; ck < thiscomp.terminals; ck++){
        if(checkpuck.connectedWires[ck] == null){
          return false;
        }
      }
    }   
  }
  
  for(Puck chkpuck:pucks){
    String thisline = "";
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      thisline += thiscomp.NGname + chkpuck.id + " ";
      //print(thiscomp.NGname + chkpuck.id + " ");
      for(int ck = 0; ck < thiscomp.terminals; ck++){
        if(chkpuck.connectedWires[ck] == null){
          return false;
        }else{
          thisline += chkpuck.connectedWires[ck].id + " ";
          //print(chkpuck.connectedWires[ck].id + " ");
        }
      }
      thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
      lines.append(thisline);
      //println(chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix));
    }
  }
  
  
  //.control
  //op
  //print allv
  //.endc
  //.end
  
  lines.append(".control");
  lines.append("op");
  lines.append("print allv");
  lines.append(".endc");
  lines.append(".end");
  
  String[] string = new String[1];
  String savepath = "data/lines.txt";
  saveStrings(savepath, lines.array(string));
  
  String thepath = sketchPath() + "/" + savepath;
  
  exec(output, errors, "/usr/local/bin/ngspice", thepath);

  for(int o = 0; o < output.size(); o++){
    String line = output.get(o);
    print(o + ": ");
    println(line);
  }
  
  for(String line: errors){
    println(line);
  }
  
  return true;
}



boolean checkCircuit(){
  checked = true;
  StringList lines = new StringList();
  
  lines.append("HEHE"); //TITLE
  
  for(Puck chkpuck:pucks){
    String thisline = "";
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      thisline += thiscomp.NGname + chkpuck.id + " ";
      //print(thiscomp.NGname + chkpuck.id + " ");
      for(int ck = 0; ck < thiscomp.terminals; ck++){
        if(chkpuck.connectedWires[ck] == null){
          return false;
        }else{
          thisline += chkpuck.connectedWires[ck].id + " ";
          //print(chkpuck.connectedWires[ck].id + " ");
        }
      }
      thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
      lines.append(thisline);
      //println(chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix));
    }
  }
  
  
  //.control
  //op
  //print allv
  //.endc
  //.end
  
  lines.append(".control");
  lines.append("op");
  lines.append("print allv");
  lines.append(".endc");
  lines.append(".end");
  
  String[] string = new String[1];
  String savepath = "data/lines.txt";
  saveStrings(savepath, lines.array(string));
  
  String thepath = sketchPath() + "/" + savepath;
  
  exec(output, errors, "/usr/local/bin/ngspice", thepath);

  for(int o = 0; o < output.size(); o++){
    String line = output.get(o);
    print(o + ": ");
    println(line);
  }
  
  for(String line: errors){
    println(line);
  }
  
  return true;
}
