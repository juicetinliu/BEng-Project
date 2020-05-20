void mousePressed(){
  //boolean oneselected = false;
  if(mouseButton == LEFT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        if(removemode){
          thispuck.removeConnections();
          pucks.remove(thispuck);
          removemode = false;
        }else{
          thispuck.select();
        }
        return;
      }
    }
    for(Button thisbutton:buttons){
      if(thisbutton.clicked()){
        thisbutton.doAction();
        return;
      }
    }
  }else if(mouseButton == RIGHT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        if(circuitRun){
          return;
        }
        thispuck.removeConnections();
        return;
      }
    }
  }
}

void mouseReleased(){
  for(Puck thispuck:pucks){
    thispuck.selected = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  for(Puck thispuck:pucks){
    if(thispuck.selected){
      thispuck.mouseRotate(e);
    }
  }
}

void keyPressed(){
  //print(keyCode);
  if(keyCode == 88){ //X
    showDebug = !showDebug;
  }
}
