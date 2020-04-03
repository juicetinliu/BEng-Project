void mousePressed(){
  //boolean oneselected = false;
  if(mouseButton == LEFT){
    for(puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        thispuck.selected = true;
        thispuck.mouseoffx = mouseX - thispuck.x;
        thispuck.mouseoffy = mouseY - thispuck.y;
        break;
      }
    }
  }else if(mouseButton == RIGHT){
    for(puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        for(puck otherpuck:thispuck.connectedpucks){
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
  for(puck thispuck:pucks){
    thispuck.selected = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  for(puck thispuck:pucks){
    if(thispuck.selected){
      if(!thispuck.onspace){
        thispuck.selectcomponent();
        if(e > 0){
          thispuck.comrotation = (thispuck.comrotation + 10) % 360;
        }else{
          thispuck.comrotation = (thispuck.comrotation - 10) % 360;
          if(thispuck.rotation < 0){
            thispuck.comrotation = thispuck.comrotation + 360;
          }
        }
      }else{
        if(e > 0){
          thispuck.rotation = (thispuck.rotation + 10) % 360;
        }else{
          thispuck.rotation = (thispuck.rotation - 10) % 360;
          if(thispuck.rotation < 0){
            thispuck.rotation = thispuck.rotation + 360;
          }
        }
      }
    }
  }
}
