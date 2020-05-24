class Component{
  int id;
  String name, NGname;
  char unit;
  int dPrefix, preHi, preLo;
  int dValue, valHi, valLo;
  int dState, noStates;
  int dType, noTypes;
  boolean valueChange;
  int terminals;
  
  Component(int id, String name, String NGname, int terminals, char unit, int dPrefix, int preHi, int preLo, int dValue, int valHi, int valLo, boolean valueChange, int noStates, int noTypes){
    this.id = id;
    this.name = name;
    this.NGname = NGname;
    this.unit = unit;
    this.dPrefix = dPrefix;
    this.dValue = dValue;
    this.valueChange = valueChange;
    this.preHi = preHi;
    this.preLo = preLo;
    this.valHi = valHi; 
    this.valLo = valLo;
    this.terminals = terminals;
    this.noStates = noStates;
    this.dState = 0;
    this.dType = 0;
    this.noTypes = noTypes;
  }
  
  Component(int id, String name, String NGname, int terminals, boolean valueChange, int noStates, int noTypes){
    this.id = id;
    this.name = name;
    this.NGname = NGname;
    this.valueChange = valueChange;
    this.unit = '\0';
    this.dPrefix = '0';
    this.dValue = '0';
    this.terminals = terminals;
    this.noStates = noStates;
    this.dState = 0;
    this.dType = 0;
    this.noTypes = noTypes;
  }
  
  String fullTypeName(int type){
    switch(id){
      case 0: //default: wire
        return name;
      
      case 1: //resistor
        return name;
      
      case 2: //capacitor
        return name;
      
      case 3: //switch
        return name;
      
      case 4: //inductor
        return name;
      
      case 5: //voltage source
        switch(type){
          case 0: //DC
            return "DC " + name;
          
          case 1: //AC - Sinusoidal
            return "Sinusoidal " + name;
          
          case 2: //AC - Triangle
            return "Triangular Wave " + name;
          
          case 3: //AC - Square
            return "Square Wave " + name;
          
          default:
            return name;
        }
      
      case 6: //diode
        return name;
      
      case 7: //BJT
        switch(type){
          case 0: //NPN
            return "NPN " + name;
          
          case 1: //PNP
            return "PNP " + name;
          
          default: //NPN
            return "NPN " + name;
        }
      
      default: //wire
        return "Wire ";
    }
  }
  
  void drawComponent(float x, float y, float size, float rotation, int strokeweight, boolean customcolour, int state, int type){
    pushMatrix();
    translate(x,y);
    rotate(radians(rotation));
    if(!customcolour){
      stroke(255);
      strokeWeight(strokeweight);
      noFill();
    }
    switch(id){
      case 0: //default: wire
        line(-size/2,0,size/2,0);
      break;
      
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
        switch(state){
          case 0:
            line(-size*0.3,0,size*0.25,-size*0.25);
            line(-size/2,0,-size*0.3,0);
            line(size/2,0,size*0.3,0);
          break;
          
          case 1:
            line(-size*0.3,0,size*0.3,0);
            line(-size/2,0,-size*0.3,0);
            line(size/2,0,size*0.3,0);
          break;
          
          default:
            line(-size*0.3,0,size*0.25,-size*0.25);
            line(-size/2,0,-size*0.3,0);
            line(size/2,0,size*0.3,0);
          break;
        }
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
        switch(type){
          case 0: //DC
            line(size*0.2,0,size*0.3,0);
            line(size*0.25,size*0.05,size*0.25,-size*0.05);
            line(-size*0.2,0,-size*0.3,0);
            ellipse(0,0,size,size);
          break;
          
          case 1: //AC - Sinusoidal
            arc(-size*0.2,0,size*0.4,size*0.4,PI,2*PI);
            arc(size*0.2,0,size*0.4,size*0.4,0,PI);
            ellipse(0,0,size,size);
          break;
          
          case 2: //AC - Triangle
            line(-size*0.4,0,-size*0.2,-size*0.2);
            line(-size*0.2,-size*0.2,size*0.2,size*0.2);
            line(size*0.4,0,size*0.2,size*0.2);
            ellipse(0,0,size,size);
          break;
          
          case 3: //AC - Square
            line(-size*0.4,0,-size*0.4,-size*0.2);
            line(-size*0.4,-size*0.2,0,-size*0.2);
            line(0,-size*0.2,0,size*0.2);
            line(0,size*0.2,size*0.4,size*0.2);
            line(size*0.4,size*0.2,size*0.4,0);
            ellipse(0,0,size,size);
          break;
          
          default:
            line(size*0.2,0,size*0.3,0);
            line(size*0.25,size*0.05,size*0.25,-size*0.05);
            line(-size*0.2,0,-size*0.3,0);
            ellipse(0,0,size,size);
          break;
        }
      break;
      
      case 6: //diode
        triangle(size*0.15,-size*0.2,size*0.15,size*0.2,-size*0.15,0);
        line(-size/2,0,-size*0.15,0);
        line(size/2,0,size*0.15,0);
        line(-size*0.15,-size*0.2,-size*0.15,size*0.2);
      break;
      
      case 7: //BJT
        switch(type){
          case 0: //NPN
            line(-size/2,0,-size*0.15,0);
            line(-size*0.15,-size*0.3,-size*0.15,size*0.3);
            line(-size*0.15,-size*0.15,size*0.15,-size*0.35);
            line(-size*0.15,size*0.15,size*0.06,size*0.29);
            line(size*0.15,-size*0.35,size*0.15,-size/2);
            line(size*0.15,size*0.35,size*0.15,size/2);
            triangle(size*0.14,size*0.34,size*0.09,size*0.25,size*0.03,size*0.33);
            ellipse(0,0,size,size);
          break;
          
          case 1: //PNP
            line(-size/2,0,-size*0.15,0);
            line(-size*0.15,-size*0.3,-size*0.15,size*0.3);
            line(-size*0.15,-size*0.15,size*0.15,-size*0.35);
            line(-size*0.06,size*0.21,size*0.15,size*0.35);
            line(size*0.15,-size*0.35,size*0.15,-size/2);
            line(size*0.15,size*0.35,size*0.15,size/2);
            triangle(-size*0.15,size*0.15,-size*0.03,size*0.17,-size*0.09,size*0.25);
            ellipse(0,0,size,size);
          break;
          
          default: //NPN
            line(-size/2,0,-size*0.15,0);
            line(-size*0.15,-size*0.3,-size*0.15,size*0.3);
            line(-size*0.15,-size*0.15,size*0.15,-size*0.35);
            line(-size*0.15,size*0.15,size*0.06,size*0.29);
            line(size*0.15,-size*0.35,size*0.15,-size/2);
            line(size*0.15,size*0.35,size*0.15,size/2);
            triangle(size*0.14,size*0.34,size*0.09,size*0.25,size*0.03,size*0.33);
            ellipse(0,0,size,size);
          break;
        }
        
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
