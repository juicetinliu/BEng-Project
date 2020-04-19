void mousePressed(){
  //boolean oneselected = false;
  if(mouseButton == LEFT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        thispuck.select();
        return;
      }
    }
  }else if(mouseButton == RIGHT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        if(!thispuck.noConnections()){
          thispuck.removeConnections();
        }
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
      if(thispuck.currZone == 0){
        if(e > 0){
          thispuck.comrotation = limdegrees(thispuck.comrotation + 10);
          thispuck.selectComponent();
          thispuck.showMenu();
        }else{
          thispuck.comrotation = limdegrees(thispuck.comrotation - 10);
          thispuck.selectComponent();
          thispuck.showMenu();
        }
      }else if(thispuck.currZone == 1){
        float mult = pow(10,min(2,int(abs(e)/4)));
        e = e*mult;
        if(e > 0){
          if(thispuck.selectComValue(int(e))){
            thispuck.valrotation = int(thispuck.selectedvalue*0.36);
          }
          thispuck.showMenu();
        }else{
          if(thispuck.selectComValue(int(e))){
            thispuck.valrotation = int(thispuck.selectedvalue*0.36);
          }
          thispuck.showMenu();
        }
      }else if(thispuck.currZone == 2){
        //if(runzone.state == 2){
        //  if(e > 0){
        //    runzone.loadUp();
        //  }else{
        //    runzone.loadDown();
        //  }
        //}
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
