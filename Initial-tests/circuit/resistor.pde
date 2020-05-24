class Resistor extends Element{
  float resistance;
  Resistor(int x1, int y1, int x2, int y2){
    super(x1,y1,x2,y2);
  }
  
  void calculateCurrent() {
      current = (volts[0]-volts[1])/resistance;
  }
  
  void show(){
    
  }
  
}
