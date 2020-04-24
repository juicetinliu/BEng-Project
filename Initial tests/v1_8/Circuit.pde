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

boolean checkCircuit(){ 
  boolean voltagesource = false;
  for(int p = 0; p < pucks.size(); p++){
    Puck checkpuck = pucks.get(p);
    if(!checkpuck.MASTERPUCK){
      Component thiscomp = checkpuck.selectedComponent;
      for(int ck = 0; ck < thiscomp.terminals; ck++){
        if(checkpuck.connectedWires[ck] == null){
          return false;
        }
      }
      if(thiscomp.id == 5){
        voltagesource = true;
      }
    }   
  }
  if(voltagesource){
    return true;
  }else{
    return false;
  }
}

void NGCircuit(){
  StringList lines = new StringList();
  
  lines.append("HEHE"); //TITLE
  
  for(Puck chkpuck:pucks){
    String thisline = "";
    if(!chkpuck.MASTERPUCK){
      Component thiscomp = chkpuck.selectedComponent;
      if(thiscomp.id != 0 || thiscomp.id != 3){
        thisline += thiscomp.NGname + chkpuck.id + " ";
        for(int ck = 0; ck < thiscomp.terminals; ck++){
          thisline += chkpuck.connectedWires[ck].id + " ";
        }
        thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
        lines.append(thisline);
      }
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
  
  NGparseOutput(output);
  for(Wire tw:wires){
    tw.showVoltages();
  }
}

void NGparseOutput(StringList output){
  for(int o = 7; o < output.size(); o++){
    String line = output.get(o);
    String[] list = split(line, " = ");
    wires.get(o-6).updateVoltage(float(list[1].trim()));
  }
}

//boolean OLDcheckCircuit(){
//  checked = true;
//  StringList lines = new StringList();
  
//  lines.append("HEHE"); //TITLE
  
//  for(Puck chkpuck:pucks){
//    String thisline = "";
//    if(!chkpuck.MASTERPUCK){
//      Component thiscomp = chkpuck.selectedComponent;
//      thisline += thiscomp.NGname + chkpuck.id + " ";
//      //print(thiscomp.NGname + chkpuck.id + " ");
//      for(int ck = 0; ck < thiscomp.terminals; ck++){
//        if(chkpuck.connectedWires[ck] == null){
//          return false;
//        }else{
//          thisline += chkpuck.connectedWires[ck].id + " ";
//          //print(chkpuck.connectedWires[ck].id + " ");
//        }
//      }
//      thisline += chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix);
//      lines.append(thisline);
//      //println(chkpuck.selectedvalue + intCodetoNGCode(chkpuck.selectedprefix));
//    }
//  }
  
  
//  //.control
//  //op
//  //print allv
//  //.endc
//  //.end
  
//  lines.append(".control");
//  lines.append("op");
//  lines.append("print allv");
//  lines.append(".endc");
//  lines.append(".end");
  
//  String[] string = new String[1];
//  String savepath = "data/lines.txt";
//  saveStrings(savepath, lines.array(string));
  
//  String thepath = sketchPath() + "/" + savepath;
  
//  exec(output, errors, "/usr/local/bin/ngspice", thepath);

//  for(int o = 0; o < output.size(); o++){
//    String line = output.get(o);
//    print(o + ": ");
//    println(line);
//  }
  
//  for(String line: errors){
//    println(line);
//  }
  
//  return true;
//}

//ArrayList<Wire> visited = new ArrayList<Wire>();
//boolean circuitCycle(){
//  visited.clear();
//  for(Wire thisWire:wires){
//    if(!visited.contains(thisWire)){
//      if(circuitHasCycle(thisWire, null)){
//        println("OK " + thisWire.id + " KO");
//        return true;
//      }
//    }
//  }
//  return false;
//}

//boolean circuitHasCycle(Wire currWire, Wire parentWire){
//  visited.add(currWire);
//  if(parentWire != null){
//    print("Check Wire " + currWire.id + " Parent " + parentWire.id + "(");
//  }else{
//    print("Check Wire " + currWire.id + " Parent null(");
//  }
  
//  for(Puck currPuck:currWire.connectedPucks){
//    if(!currPuck.MASTERPUCK){
//      print(" P" + currPuck.id + "[");
//      Component thiscomp = currPuck.selectedComponent;
//      for(int c = 0; c < thiscomp.terminals; c++){
//        if(currPuck.connectedWires[c] != null){
//          Wire nextWire = currPuck.connectedWires[c];
//          print(" W" + nextWire.id);
//          if(!visited.contains(nextWire)){
//            print("N");
//            if(circuitHasCycle(nextWire, currWire)){
//              print(")");
//              return true;
//            }else{
//              if(parentWire != null){
//                if(!nextWire.equals(parentWire)){
//                  print("SHAREPARENT )" + nextWire.id + "P" + parentWire.id);
//                  return true;
//                }
//              }
//            }
//          }else{
//            print("V");
//            if(parentWire != null){
//              if(!nextWire.equals(parentWire)){
//                print("SHAREPARENT )" + nextWire.id + "P" + parentWire.id);
//                return true;
//              }
//            }
//          }
//        }
//      }
//      print("]");
//    }
//  }
//  println(")");
//  return false;
//}
