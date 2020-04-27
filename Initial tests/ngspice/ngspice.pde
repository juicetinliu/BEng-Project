StringList output = new StringList();
StringList errors = new StringList();
boolean runonce = true;

int sendtimer = millis();

void setup(){
   size(200,200); 
}

void draw(){
  //if(mspassed(sendtimer, 1000)){
  //  sendtimer = millis();
  //  print(sendtimer);
  //}
  if(runonce){
    runonce = false;
    output.clear();
    errors.clear();
    println("running");
    print(sketchPath());
    int hi = exec(output, errors, "/usr/local/bin/ngspice", "Desktop/first.txt");
    println("returned " + hi);
    for(int o = 0; o < output.size(); o++){
      String line = output.get(o);
      print(o + ": ");
      println(line);
    }
    
    for(String line: errors){
      println(line);
    }
  }
}

void mousePressed(){
  runonce = true;
}

boolean mspassed(int starttime, int interval){
  return millis() > starttime + interval;
}
