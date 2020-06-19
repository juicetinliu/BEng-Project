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
          text("Toggle Graph", x + size/1.5, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        
        line(size/4,0,-size/4,0);
        line(-size/4,size/4,-size/4,-size/4);
        stroke(255,128);
        arc(size/8,0,size/4,size/2,0,PI);
        arc(-size/8,0,size/4,size/2,PI,2*PI);
        popMatrix();
      break;
      
      case "Settings":
        stroke(255);
        strokeWeight(2);
        if(pointincircle(mouseX,mouseY,x,y,size)){
          fill(255);
          text("Settings", x + size/1.5, y);
          fill(255,128);
        }else{
          noFill();
        }
        pushMatrix();
        translate(x,y);
        ellipse(0,0,size,size);
        
        gearIC.display(0,0,size/3,true,color(0),color(255),2);
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
        pucks.add(new Puck(pucks.size()+1, x, y,puckSize, shakeSettings, scrollSettings));
      break;
      
      case "RemovePucks":
        graphmode = false;
        removemode = !removemode;
      break;
      
      case "AddGraph":
        removemode = false;
        graphmode = !graphmode;
      break;
      
      case "Settings":
        settingsOpen = !settingsOpen;
      break;
      
      default:
      break;
    }
  }
}

class Slider{
  String purpose;
  float x, y;
  float size;
  boolean selected;
  float ballsize, ballval, ballx;
  
  Slider(String purpose, float x, float y, float size, float ballsize){
    this.purpose = purpose;
    this.x = x;
    this.y = y;
    this.size = size;
    this.ballsize = ballsize;
    this.ballval = 0.5;
    this.selected = false;
    mapballx();
  }
  
  
  void display(){
    switch(purpose){
      case "Shakesen":
        stroke(255);
        strokeWeight(2);
        pushMatrix();
        translate(x,y);
        line(-size/2,-ballsize/2,-size/2,ballsize/2);
        line(size/2,-ballsize/2,size/2,ballsize/2);
        line(0,-ballsize/2,0,ballsize/2);
        line(-size/2,0,size/2,0);
        if(pointincircle(mouseX,mouseY,x+ballx,y,ballsize) || selected){
          fill(128);
        }else{
          fill(0);
        }
        ellipse(ballx,0,ballsize,ballsize);
        
        if(selected){
          fill(255);
          textAlign(CENTER);
          text("More Sensitive", size/2, -ballsize);
          text("Less Sensitive", -size/2, -ballsize);
        }
        popMatrix();
      break;
      
      case "Scrollsen":
        stroke(255);
        strokeWeight(2);
        pushMatrix();
        translate(x,y);
        line(-size/2,-ballsize/2,-size/2,ballsize/2);
        line(size/2,-ballsize/2,size/2,ballsize/2);
        line(0,-ballsize/2,0,ballsize/2);
        line(-size/2,0,size/2,0);
        if(pointincircle(mouseX,mouseY,x+ballx,y,ballsize) || selected){
          fill(128);
        }else{
          fill(0);
        }
        ellipse(ballx,0,ballsize,ballsize);
        
        if(selected){
          fill(255);
          textAlign(CENTER);
          text("More Sensitive", size/2, -ballsize);
          text("Less Sensitive", -size/2, -ballsize);
        }
        popMatrix();
      break;
      
      default:
      break;
    }
  }
  
  void mapballx(){
    ballx = map(ballval,0,1,-size/2,size/2);;
  }
  
  
  boolean clicked(){
    return pointincircle(mouseX,mouseY,x+ballx,y,ballsize);
  }
  
  void doAction(){
    switch(purpose){
      case "Shakesen":
        shakeSettings = ballval;
        for(Puck tp:pucks){
          tp.setShakeSettings(shakeSettings);
        }
      break;
      
      case "Scrollsen":
        scrollSettings = ballval;
        for(Puck tp:pucks){
          tp.setScrollSettings(scrollSettings);
        }
      break;
      
      case "DiscSize":
      break;
      
      case "DiscRotType":
      break;
      
      default:
      break;
    }
  }
  void select(){
    selected = true;
  }
  
  void mouseMove(){
    ballx = min(max(mouseX-x,-size/2),size/2);
    ballval = map(ballx,-size/2,size/2,0,1);
  }
  
  void run(){
    if(selected){
      mouseMove();
      doAction();
    }
  }
}
