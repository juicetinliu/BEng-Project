class ComponentCategory{ //CATEGORY
  int id;
  String name;
  ArrayList<Component> cat = new ArrayList<Component>();
  int repCompID;
  
  ComponentCategory(int id, String name, int representative){
    this.id = id;
    this.name = name;
    this.repCompID = representative;
  }
  
  void drawCategory(float x, float y, float size, float rotation, int strokeweight, boolean customcolour, int state){
    cat.get(repCompID).drawComponent(x, y, size, rotation, strokeweight, customcolour, state);
  }
  
  void addComponent(Component newComp){
    cat.add(newComp);
  }
  
  int indComponent(Component thiscomp){
    return cat.indexOf(thiscomp);
  }
}

class Component{
  int id;
  boolean NGusable;
  String name, NGname;
  boolean valueChange;
  String unit;
  int dPrefix, preHi, preLo;
  int dValue, valHi, valLo;
  int dState, noStates;
  int terminals;
  
  boolean timeChange = false;
  String tunit;
  int dTPrefix, TpreHi, TpreLo;
  int dTValue, TvalHi, TvalLo;
  
  
  Component(int id, boolean NGusable, String name, String NGname, int terminals, String unit, int dPrefix, int preHi, int preLo, int dValue, int valHi, int valLo, boolean valueChange, int noStates){
    this.id = id;
    this.NGusable = NGusable;
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
  }
  
  Component(int id, boolean NGusable, String name, String NGname, int terminals, boolean valueChange, int noStates){
    this.id = id;
    this.NGusable = NGusable;
    this.name = name;
    this.NGname = NGname;
    this.valueChange = valueChange;
    this.unit = "";
    this.dPrefix = 0;
    this.dValue = 0;
    this.terminals = terminals;
    this.noStates = noStates;
    this.dState = 0;
  }
  
  void setTime(String tunit, int dTPrefix, int TpreHi, int TpreLo, int dTValue, int TvalHi, int TvalLo){
    this.tunit = tunit;
    this.dTPrefix = dTPrefix;
    this.dTValue = dTValue;
    this.timeChange = true;
    this.TpreHi = TpreHi;
    this.TpreLo = TpreLo;
    this.TvalHi = TvalHi; 
    this.TvalLo = TvalLo;
  }
  
  void drawComponent(float x, float y, float size, float rotation, int strokeweight, boolean customcolour, int state){
    rectMode(CENTER);
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
      
      case 3: //inductor
        line(-size/2,0,-size*0.4,0);
        line(size/2,0,size*0.4,0);
        arc(size*0.3,0,size*0.2,size*0.2,PI,2*PI);
        arc(size*0.1,0,size*0.2,size*0.2,PI,2*PI);
        arc(-size*0.1,0,size*0.2,size*0.2,PI,2*PI);
        arc(-size*0.3,0,size*0.2,size*0.2,PI,2*PI);
      break;
      
      case 4: //switch
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
      
      case 5: //DC
        line(size*0.2,0,size*0.3,0);
        line(size*0.25,size*0.05,size*0.25,-size*0.05);
        line(-size*0.2,0,-size*0.3,0);
        ellipse(0,0,size,size);
      break;
      
      case 6: //AC - Sinusoidal
        arc(-size*0.2,0,size*0.4,size*0.4,PI,2*PI);
        arc(size*0.2,0,size*0.4,size*0.4,0,PI);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5,0,size*0.5,0);
        stroke(255);
      break;
      
      case 7: //AC - Triangle
        line(-size*0.4,0,-size*0.2,-size*0.2);
        line(-size*0.2,-size*0.2,size*0.2,size*0.2);
        line(size*0.4,0,size*0.2,size*0.2);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5,0,size*0.5,0);
        stroke(255);
      break;
      
      case 8: //AC - Square
        line(-size*0.4,0,-size*0.4,-size*0.2);
        line(-size*0.4,-size*0.2,0,-size*0.2);
        line(0,-size*0.2,0,size*0.2);
        line(0,size*0.2,size*0.4,size*0.2);
        line(size*0.4,size*0.2,size*0.4,0);
        ellipse(0,0,size,size);
        stroke(255,50);
        line(-size*0.5,0,size*0.5,0);
        stroke(255);
      break;
      
      case 9: //diode
        triangle(size*0.15,-size*0.2,size*0.15,size*0.2,-size*0.15,0);
        line(-size/2,0,-size*0.15,0);
        line(size/2,0,size*0.15,0);
        line(-size*0.15,-size*0.2,-size*0.15,size*0.2);
      break;
      
      case 10: //NPN
        line(-size/2,0,-size*0.15,0);
        line(-size*0.15,-size*0.3,-size*0.15,size*0.3);
        line(-size*0.15,-size*0.15,size*0.15,-size*0.35);
        line(-size*0.15,size*0.15,size*0.06,size*0.29);
        line(size*0.15,-size*0.35,size*0.15,-size/2);
        line(size*0.15,size*0.35,size*0.15,size/2);
        triangle(size*0.14,size*0.34,size*0.09,size*0.25,size*0.03,size*0.33);
        ellipse(0,0,size,size);
      break;
      
      case 11: //PNP
        line(-size/2,0,-size*0.15,0);
        line(-size*0.15,-size*0.3,-size*0.15,size*0.3);
        line(-size*0.15,-size*0.15,size*0.15,-size*0.35);
        line(-size*0.06,size*0.21,size*0.15,size*0.35);
        line(size*0.15,-size*0.35,size*0.15,-size/2);
        line(size*0.15,size*0.35,size*0.15,size/2);
        triangle(-size*0.15,size*0.15,-size*0.03,size*0.17,-size*0.09,size*0.25);
        ellipse(0,0,size,size);
      break;
      
      case 12: //Oscilloscope
        line(-size*0.5,-size*0.07,-size*0.2,-size*0.07);
        line(-size*0.5,size*0.07,-size*0.2,size*0.07);
        line(-size*0.2,-size*0.07,size*0.45,-size*0.02);
        line(-size*0.2,size*0.07,size*0.45,size*0.02);
        line(size*0.45,-size*0.02,size*0.45,size*0.02);
        rect(-size*0.2,0,size*0.04,size*0.4);
        ellipse(0,0,size,size);
      break;
      
      case 13: //VOLTMETER
        line(-size*0.05,-size*0.07,0,size*0.07);
        line(size*0.05,-size*0.07,0,size*0.07);
        
        ellipse(0,0,size,size);
        line(size*0.2,0,size*0.3,0);
        line(size*0.25,size*0.05,size*0.25,-size*0.05);
        line(-size*0.2,0,-size*0.3,0);
      break;
      
      case 14: //AMMETER
        line(-size*0.05,size*0.07,0,-size*0.07);
        line(size*0.025,size*0.02,-size*0.025,size*0.02);
        line(size*0.05,size*0.07,0,-size*0.07);
        
        ellipse(0,0,size,size);
        line(size*0.2,0,size*0.3,0);
        line(size*0.25,size*0.05,size*0.25,-size*0.05);
        line(-size*0.2,0,-size*0.3,0);
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
      return str(value) + str(intCodetoPrefix(prefixCode)) + unit;
    }
  }
  
  String generateComponentTimeText(int value, int prefixCode){
    if(!timeChange){
      return "";
    }else{
      return str(value) + str(intCodetoPrefix(prefixCode)) + tunit;
    }
  }
  
}

void drawOscilloscope(float size, float rotation){
  pushMatrix();
  rotate(radians(rotation));
  line(0, -size*0.07, 0, size*0.07);
  line(0, -size*0.07, -size*0.25, size*0.07);
  line(0, size*0.07, size*0.25, -size*0.07); 
  popMatrix();
}
