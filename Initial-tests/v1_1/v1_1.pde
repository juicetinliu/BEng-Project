ArrayList<puck> pucks = new ArrayList<puck>();

void setup(){
  size(1200,800);
  //smooth();
  pixelDensity(displayDensity());
  pucks.add(new puck(1, width/2,height/2,50));
  pucks.add(new puck(2, width/4,height/2,50));
  //pucks.add(new puck(3, width*3/4,height/2,50));
  //pucks.add(new puck(4, width/2,height/4,50));
  //pucks.add(new puck(5, width/2,height*3/4,50));

}
void draw(){
  background(0);
  
  fill(255);
  text(frameRate,10,10);
  
  fill(128,100);
  strokeWeight(1);
  stroke(255);
  rectMode(CENTER);
  rect(width/2,height*0.9,width,height*0.2);
  
  for(puck thispuck:pucks){
    thispuck.display();
    if(thispuck.selected){
      thispuck.mouseMove();
    }
    //if(thispuck.beginconnection){
    //  thispuck.connect
    //}
  }
  checkAuras(pucks);
  checkPuckSpace(pucks);
}

void checkPuckSpace(ArrayList<puck> allpucks){
  for(puck thispuck:allpucks){
    if(circleinrect(thispuck.x,thispuck.y,thispuck.size,width/2,height*0.9,width,height*0.2)){
      
      thispuck.onspace = false;
    }else{
      thispuck.onspace = true;
    }
  }
  
}

void checkAuras(ArrayList<puck> allpucks){
  
  for(puck thispuck:allpucks){
    thispuck.beginconnection = false;
  }
  
  if(allpucks.size() > 1){
    for(int p1 = 0; p1 < allpucks.size(); p1++){
      for(int p2 = p1 + 1; p2 < allpucks.size(); p2++){
        puck thispuck = allpucks.get(p1);
        puck thatpuck = allpucks.get(p2);
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
