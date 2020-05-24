class Button{
  String purpose;
  float x, y;
  float size;
  
  Button(String purpose, float x, float y, float size){
    this.purpose = purpose;
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  
  void display(){
    textAlign(LEFT,CENTER);
    switch(purpose){
      case "AddPucks":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Add Disc", x + size/1.5, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        line(size/4,0,-size/4,0);
        line(0,size/4,0,-size/4);
        popMatrix();
      break;
      
      case "RemovePucks":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Remove Disc", x + size/1.5, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        line(size/4,0,-size/4,0);
        popMatrix();
      break;
      
      case "AddGraph":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Attach Graph", x + size/1.5, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        
        line(size/4,0,-size/4,0);
        line(-size/4,size/4,-size/4,-size/4);
        arc(size/8,0,size/4,size/2,0,PI);
        arc(-size/8,0,size/4,size/2,PI,2*PI);
        popMatrix();
      break;
      
      default:
      break;
    }
  }
  
  
  boolean clicked(){
    return pointincircle(mouseX,mouseY,x,y,size);
  }
  
  void doAction(){
    switch(purpose){
      case "AddPucks":
        pucks.add(new Puck(pucks.size()+1, x, y,puckSize));
      break;
      
      case "RemovePucks":
        removemode = !removemode;
      break;
      
      case "AddGraph":
        graphmode = !graphmode;
      break;
      
      default:
      break;
    }
  }
}
