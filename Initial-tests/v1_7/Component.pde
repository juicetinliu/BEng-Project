class Component{
  int id;
  String name;
  char unit;
  int dPrefix, preHi, preLo;
  int dValue, valHi, valLo;
  boolean valueChange;
  int terminals;
  
  Component(int id, String name, int terminals, char unit, int dPrefix, int preHi, int preLo, int dValue, int valHi, int valLo, boolean valueChange){
    this.id = id;
    this.name = name;
    this.unit = unit;
    this.dPrefix = dPrefix;
    this.dValue = dValue;
    this.valueChange = valueChange;
    this.preHi = preHi;
    this.preLo = preLo;
    this.valHi = valHi; 
    this.valLo = valLo;
    this.terminals = terminals;
  }
  
  Component(int id, String name, int terminals, boolean valueChange){
    this.id = id;
    this.name = name;
    this.valueChange = valueChange;
    this.unit = '\0';
    this.dPrefix = '0';
    this.dValue = '0';
    this.terminals = terminals;
  }
  
  void drawComponent(float x, float y, float size, float rotation, int strokeweight, boolean customcolour){
    pushMatrix();
    translate(x,y);
    rotate(radians(rotation));
    if(!customcolour){
      stroke(255);
      strokeWeight(strokeweight);
      noFill();
    }
    switch(id){
      case 1: //resistor
        rectMode(CENTER);
        rect(0,0,size*0.8,size*0.2);
        line(-size/2,0,-size*0.4,0);
        line(size/2,0,size*0.4,0);
      break;
      
      case 2: //capacitor
        line(-size*0.1,size*0.25,-size*0.1,-size*0.25);
        line(size*0.1,size*0.25,size*0.1,-size*0.25);
        line(-size/2,0,-size*0.1,0);
        line(size/2,0,size*0.1,0);
      break;
      
      case 3: //switch
        line(-size*0.3,0,size*0.25,-size*0.25);
        line(-size/2,0,-size*0.3,0);
        line(size/2,0,size*0.3,0);
      break;
      
      case 4: //inductor
        line(-size/2,0,-size*0.4,0);
        line(size/2,0,size*0.4,0);
        arc(size*0.3,0,size*0.2,size*0.2,PI,2*PI);
        arc(size*0.1,0,size*0.2,size*0.2,PI,2*PI);
        arc(-size*0.1,0,size*0.2,size*0.2,PI,2*PI);
        arc(-size*0.3,0,size*0.2,size*0.2,PI,2*PI);
      break;
      
      case 5: //voltage source
        line(size*0.2,0,size*0.3,0);
        line(size*0.25,size*0.05,size*0.25,-size*0.05);
        line(-size*0.2,0,-size*0.3,0);
        ellipse(0,0,size,size);
      break;
      
      default: //wire
        line(-size/2,0,size/2,0);
      break;
    }
    popMatrix();
  }
  
  String generateComponentText(int value, int prefixCode){
    if(!valueChange){
      return "";
    }else{
      return str(value) + str(intCodetoPrefix(prefixCode)) + str(unit);
    }
  }
  
}
