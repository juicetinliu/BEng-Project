String thepath = "C:/Users/taiwa/Documents/GitHub/BEng-Project/Complete-tests/win1/data/lines.txt";

StringList output = new StringList();
StringList errors = new StringList();
String[] params = {"C:/Spice64/bin/ngspice_con.exe", thepath};
//launch("cd /Users/taiwa/Documents/ngspice-32_64/Spice64/bin/ngspice.exe");
  //exec("cd C:/Spice64/bin/ngspice_con.exe");
//exec(output, errors, "cd Documents/ngspice-32_64/Spice64/bin/ngspice_con.exe");
exec(output, errors, "C:/Spice64/bin/ngspice_con.exe", thepath);
for(int o = 0; o < output.size(); o++){
  String line = output.get(o);
  print(o + ": ");
  println(line);
}

for(String line: errors){
  print("ERR: ");
  println(line);
}
