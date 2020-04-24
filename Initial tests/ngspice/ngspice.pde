StringList output = new StringList();
StringList errors = new StringList();
void setup(){
   size(200,200); 
}

void draw(){
  
}

void mousePressed(){
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
