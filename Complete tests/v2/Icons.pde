class Icon{
  String name;
  Icon(String name){
    this.name = name;
  }
  
  void display(float x, float y, float size, boolean nf, color fc, color sc, float sw){
    pushMatrix();
    translate(x,y);
    scale(size);
    if(nf){
      noFill();
    }else{
      //fill(fc);
    }
    if(sw == 0){
      noStroke();
    }else{
      strokeWeight(sw/size);
      stroke(sc);
    }
    switch(name){
      case "chip":
        rectMode(CENTER);
        rect(0,0,1.7,1.7,0.3,0.3,0.3,0.3);
        rect(0,0,1.4,1.4,0.1,0.1,0.1,0.1);
        ellipse(-0.45,-0.45,0.1,0.1);
        line(0.85,0,1,0);
        line(0.85,0.2,1,0.2);
        line(0.85,0.4,1,0.4);
        line(0.85,-0.2,1,-0.2);
        line(0.85,-0.4,1,-0.4);
        line(-0.85,0,-1,0);
        line(-0.85,0.2,-1,0.2);
        line(-0.85,0.4,-1,0.4);
        line(-0.85,-0.2,-1,-0.2);
        line(-0.85,-0.4,-1,-0.4);
        line(0,0.85,0,1);
        line(0.2,0.85,0.2,1);
        line(0.4,0.85,0.4,1);
        line(-0.2,0.85,-0.2,1);
        line(-0.4,0.85,-0.4,1);
        line(0,-0.85,0,-1);
        line(0.2,-0.85,0.2,-1);
        line(0.4,-0.85,0.4,-1);
        line(-0.2,-0.85,-0.2,-1);
        line(-0.4,-0.85,-0.4,-1);
      break;
      case "knob":
        ellipse(0,0,2,2);
        ellipse(0,0,1,1);
        rotate(-PI/2);
        line(0,-0.8,0,-1);
        rotate(PI/4);
        line(0,-0.8,0,-1);
        rotate(PI/4);
        line(0,-0.8,0,-1);
        rotate(PI/8);
        line(0,0,0,-0.5);
        rotate(PI/8);
        line(0,-0.8,0,-1);
        rotate(PI/4);
        line(0,-0.8,0,-1);
      break;
      
      default:
      break;
    } 
    popMatrix();
    
  }
  
  
  
}
