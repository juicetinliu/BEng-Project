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
      fill(fc);
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
      
      case "wrench":
        rotate(PI/6);
        line(0.15,-0.4,0.15,0.4);
        line(-0.15,-0.4,-0.15,0.4);
        arc(0,-0.7,0.6,0.6,2*PI/3,4*PI/3);
        arc(0,-0.7,0.6,0.6,5*PI/3,7*PI/3);
        arc(0,0.7,0.6,0.6,2*PI/3,4*PI/3);
        arc(0,0.7,0.6,0.6,5*PI/3,7*PI/3);
        line(-0.15,-0.9,-0.15,-0.7);
        line(0.15,-0.9,0.15,-0.7);
        line(-0.15,-0.7,0.15,-0.7);
        line(-0.15,0.9,-0.15,0.7);
        line(0.15,0.9,0.15,0.7);
        line(-0.15,0.7,0.15,0.7);
        noStroke();
        fill(sc);
        float r = sw/size;
        ellipse(0.15,-0.4,r,r);
        ellipse(0.15,0.4,r,r);
        ellipse(-0.15,-0.4,r,r);
        ellipse(-0.15,0.4,r,r);
        
        ellipse(-0.15,-0.9,r,r);
        ellipse(-0.15,-0.7,r,r);
        ellipse(0.15,-0.7,r,r);
        ellipse(0.15,-0.9,r,r);
        
        ellipse(-0.15,0.9,r,r);
        ellipse(-0.15,0.7,r,r);
        ellipse(0.15,0.7,r,r);
        ellipse(0.15,0.9,r,r);
      break;
      
      case "knob":

        ellipse(0,0,2,2);
        line(-1,0,-0.8,0);
        line(1,0,0.8,0);
        line(0,-1,0,-0.8);
        line(0,1,0,0.8);
        ellipse(0,0,1,1);
        rotate(PI/8);
        line(0,0,0,-0.5);
      break;
      
      case "gear":
        ellipse(0,0,1,1);
        for(int i = 0; i < 8; i++){
          arc(0,0,1.6,1.6,-PI/8,0);
          line(0.8,0,1,0);
          rotate(PI/8);
          arc(0,0,2,2,-PI/8,0);
          line(0.8,0,1,0);
          rotate(PI/8);
        }
      break;
      
      case "time":
        ellipse(0,0.125,1.75,1.75);
        line(0.25,-1,-0.25,-1);
        line(0,-1,0,-0.75);
        line(0,0,0,-0.5);
        rotate(-PI/4);
        line(0,0,0,-0.5);
      break;
      
      default:
      break;
    } 
    popMatrix();
    
  }
  
  
  
}
