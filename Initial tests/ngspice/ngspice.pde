StringList output = new StringList();
StringList errors = new StringList();
void setup(){
   size(200,200); 
}

void draw(){
  
}

void mousePressed(){
  println("running");
  int hi = exec(output, errors, "/usr/local/bin/ngspice", "Desktop/next.txt");
  println("returned " + hi);
  for(String line: output){
    println(line);
  }
  for(String line: errors){
    println(line);
  }
}
