class Puck{
  int id;
  float x, y;
  float size, aurasize;
  float rotation, comrotation;
  boolean selected, beginconnection;
  int connectclock = 0;
  float mouseoffx, mouseoffy;
  boolean onspace;
  
  int selectedcomponent, terminals = 2;
  
  Puck connectpuck = null;
  ArrayList<Puck> connectedpucks = new ArrayList<Puck>();
  
  Puck(int id, float x, float y, float size){
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.selected = false; 
    this.beginconnection = false; 
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.aurasize = 20;
    this.onspace = true;
    this.rotation = 0;
    this.comrotation = 0;
    this.selectedcomponent = 0;
  }
  
  void display(){
    fill(255);
    text(connectedpucks.size(),x,y-40);
    
    for(Puck conpuck:connectedpucks){
      stroke(255);
      strokeWeight(2);
      float angtopuck = atan2(conpuck.y-y,conpuck.x-x);
      float x1 = x + size/2*cos(angtopuck);
      float y1 = y + size/2*sin(angtopuck);
      float x2 = conpuck.x - conpuck.size/2*cos(angtopuck);
      float y2 = conpuck.y - conpuck.size/2*sin(angtopuck);
      line(x1,y1,x2,y2);
      fill(255);
    }
    
    fill(255,128);
    noStroke();
    ellipse(x, y, size + aurasize, size + aurasize);
    
    fill(255,map(connectclock,0,100,50,255));
    noStroke();
    float connectan = map(connectclock,0,100,0,aurasize);
    ellipse(x, y, size + connectan, size + connectan);
    
    
    stroke(255);
    strokeWeight(1);
    
    if(selected){
      fill(50);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        fill(128);
      }else{
        fill(0);
      }
    }
    if(!onspace){
      fill(255,0,0,128);
    }
    ellipse(x, y, size,size);
    
    stroke(255);
    strokeWeight(1);
    line(x+size*0.5*cos(radians(rotation-90)),y+size*0.5*sin(radians(rotation-90)),x+size*0.6*cos(radians(rotation-90)),y+size*0.6*sin(radians(rotation-90)));
    stroke(255,0,0);
    strokeWeight(2);
    line(x+size*0.5*cos(radians(comrotation-90)),y+size*0.5*sin(radians(comrotation-90)),x+size*0.6*cos(radians(comrotation-90)),y+size*0.6*sin(radians(comrotation-90)));
    
    drawcomponent(selectedcomponent,x,y,size,rotation);
    
    //fill(255);
    //text(rotation,x+10,y);
    //text(selectedcomponent,x-10,y);
  }
  
  void mouseMove(){
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
  }
  
  void selectcomponent(){
    selectedcomponent = int(map(comrotation,0,360,0,3));
  }
  
  void run(){
    
    if(selected){
      mouseMove();
    }
    
    if(beginconnection){
      //text("connecting",x-20,y+10);
      if(connectclock < 100){
        connectclock += 1;
      }else{
        if(!connectedpucks.contains(connectpuck)){
          connectedpucks.add(connectpuck);
          connectpuck.connectedpucks.add(this);
        }
      }
    }else{
      if(connectclock > 0){
        connectclock -= 5;
      }else{
        connectclock = 0;
      }
    }
  }
  //void connect(puck connectpuck){
    
  //}
  
}

void checkPuckSpace(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    if(circleinrect(thispuck.x,thispuck.y,thispuck.size,width/2,height*0.9,width,height*0.2)){
      thispuck.onspace = false;
    }else{
      thispuck.onspace = true;
    }
  }
}

void checkAuras(ArrayList<Puck> allpucks){
  for(Puck thispuck:allpucks){
    thispuck.beginconnection = false;
  }
  
  if(allpucks.size() > 1){
    for(int p1 = 0; p1 < allpucks.size(); p1++){
      for(int p2 = p1 + 1; p2 < allpucks.size(); p2++){
        Puck thispuck = allpucks.get(p1);
        Puck thatpuck = allpucks.get(p2);
        if(thispuck.onspace && thatpuck.onspace){
          if(!thispuck.connectedpucks.contains(thatpuck) || !thatpuck.connectedpucks.contains(thispuck)){
            if(!thispuck.beginconnection && !thatpuck.beginconnection){
              if(circleincircle(thispuck.x,thispuck.y,thispuck.size+thispuck.aurasize,thatpuck.x,thatpuck.y,thatpuck.size+thatpuck.aurasize)){
                thispuck.beginconnection = true;
                thatpuck.beginconnection = true;
                
                thispuck.connectpuck = thatpuck;
                thatpuck.connectpuck = thispuck;
              }
            }
          }
        }
      }
    }
  }
}
