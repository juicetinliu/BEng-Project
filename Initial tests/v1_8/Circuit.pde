StringList output = new StringList();
StringList errors = new StringList();

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
  //String print = "print";
  //for(Wire prtwire:wires){
  //  print += "v(" + prtwire.id + ") ";
  //}
  //lines.append(print);
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
