void mousePressed(){
  //boolean oneselected = false;
  if(mouseButton == LEFT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        thispuck.selected = true;
        thispuck.mouseoffx = mouseX - thispuck.x;
        thispuck.mouseoffy = mouseY - thispuck.y;
        return;
      }
    }
  }else if(mouseButton == RIGHT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        for(int p = 0; p < thispuck.connectedpucks.length; p++){
          if(thispuck.connectedpucks[p] != null){
            Puck otherpuck = thispuck.connectedpucks[p];
            for(int o = 0; o < otherpuck.connectedpucks.length; o++){
              otherpuck.connectedpucks[o] = null;
            }
          }
        }
        for(int p = 0; p < thispuck.connectedpucks.length; p++){
          thispuck.connectedpucks[p] = null;
        }
        return;
      }
    }
  }
}

void mouseDragged(){
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
      if(!thispuck.onspace){
        thispuck.selectComponent();
        if(e > 0){
          thispuck.comrotation = limdegrees(thispuck.comrotation + 10);
          thispuck.showMenu();
        }else{
          thispuck.comrotation = limdegrees(thispuck.comrotation - 10);
          thispuck.showMenu();
        }
      }else{
        if(e > 0){
          thispuck.rotation = limdegrees(thispuck.rotation + 10);
        }else{
          thispuck.rotation = limdegrees(thispuck.rotation - 10);
        }
      }
    }
  }
}
