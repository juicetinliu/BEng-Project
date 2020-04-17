void drawComponent(int id, float x, float y, float size, float rotation, int strokeweight, boolean customcolour){
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
    
    //case 3:
    //  line(-size*0.1,size*0.25,-size*0.1,-size*0.25);
    //  line(size*0.1,size*0.25,size*0.1,-size*0.25);
    //  line(-size/2,0,-size*0.1,0);
    //  line(size/2,0,size*0.1,0);
    //break;
    
    default: //wire
      line(-size/2,0,size/2,0);
    break;
  }
  popMatrix();
  
}

int componentToDefaultPrefix(int id){
  switch(id){
    case 1: //resistor
      return 1;
    case 2: //capacitor
      return 0;
    case 3: //switch
      return 0;
    case 4: //inductor
      return 0;
    case 5: //voltage source
      return 0;
    default: //wire
      return 0;
  }
}

int componentToDefaultValue(int id){
  switch(id){
    case 1: //resistor
      return 1;
    case 2: //capacitor
      return 1;
    case 3: //switch
      return 0;
    case 4: //inductor
      return 1;
    case 5: //voltage source
      return 5;
    default: //wire
      return 0;
  }
}

char componentToUnit(int id){
  switch(id){
    case 1: //resistor
      return 'Ω';
    case 2: //capacitor
      return 'F';
    case 3: //switch
      return 'x';
    case 4: //inductor
      return 'H';
    case 5: //voltage source
      return 'V';
    default: //wire
      return 'x';
  }
}

String generateComponentText(int component, int value, int prefixCode){
  if(component == 3 || component == 0){
    return "";
  }else{
    return str(value) + str(intCodetoPrefix(prefixCode)) + str(componentToUnit(component));
  }
}
