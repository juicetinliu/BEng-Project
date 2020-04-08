void drawComponent(int id, float x, float y, float size, float rotation, boolean customcolour){
  pushMatrix();
  translate(x,y);
  rotate(radians(rotation));
  if(!customcolour){
    stroke(255);
    strokeWeight(1);
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
