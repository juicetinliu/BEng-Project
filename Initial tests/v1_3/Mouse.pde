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
        //if(thispuck.connectedpuck1 != null){
        //  thispuck.connectedpuck1.connectedpuck1 = null;
        //  thispuck.connectedpuck1.connectedpuck2 = null;
        //}
        //if(thispuck.connectedpuck2 != null){
        //  thispuck.connectedpuck2.connectedpuck1 = null;
        //  thispuck.connectedpuck2.connectedpuck2 = null;
        //}
        //thispuck.connectedpuck2 = null;
        //thispuck.connectedpuck1 = null;
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
