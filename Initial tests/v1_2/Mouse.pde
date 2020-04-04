void mousePressed(){
  //boolean oneselected = false;
  if(mouseButton == LEFT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        thispuck.selected = true;
        thispuck.mouseoffx = mouseX - thispuck.x;
        thispuck.mouseoffy = mouseY - thispuck.y;
        break;
      }
    }
  }else if(mouseButton == RIGHT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        for(Puck otherpuck:thispuck.connectedpucks){
          otherpuck.connectedpucks.remove(thispuck);
        }
        thispuck.connectedpucks.clear();
        break;
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
        thispuck.selectcomponent();
        if(e > 0){
          thispuck.comrotation = limdegrees(thispuck.comrotation + 10);
        }else{
          thispuck.comrotation = limdegrees(thispuck.comrotation - 10);
          if(thispuck.rotation < 0){
            thispuck.comrotation = limdegrees(thispuck.comrotation + 360);
          }
        }
      }else{
        if(e > 0){
          thispuck.rotation = limdegrees(thispuck.rotation + 10);
        }else{
          thispuck.rotation = limdegrees(thispuck.rotation - 10);
          if(thispuck.rotation < 0){
            thispuck.rotation = limdegrees(thispuck.rotation + 360);
          }
        }
      }
    }
  }
}
