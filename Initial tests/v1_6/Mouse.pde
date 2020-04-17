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
        for(int w = 0; w < thispuck.connectedWires.length; w++){
          Wire thiswire = thispuck.connectedWires[w];
          if(thiswire != null){
            int puckind = thiswire.connectedPucks.indexOf(thispuck);
            if(puckind != -1){
              thiswire.connectedPucks.remove(thispuck);
              thiswire.sides.remove(puckind);
            }
            thiswire.update();
            thiswire.checkDestroy();
            thispuck.connectedWires[w] = null;
          }
          
        }
        return;
      }
    }
  }
}

//void mouseDragged(){
//}

void mouseReleased(){
  for(Puck thispuck:pucks){
    thispuck.selected = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  for(Puck thispuck:pucks){
    if(thispuck.selected){
      if(thispuck.oncomspace){
        if(e > 0){
          thispuck.comrotation = limdegrees(thispuck.comrotation + 10);
          thispuck.selectComponent();
          thispuck.showMenu();
        }else{
          thispuck.comrotation = limdegrees(thispuck.comrotation - 10);
          thispuck.selectComponent();
          thispuck.showMenu();
        }
      }else if(thispuck.onvalspace){
        float mult = pow(10,min(2,int(abs(e)/4)));
        e = e*mult;
        if(e > 0){
          if(thispuck.selectValue(int(e))){
            thispuck.valrotation = int(thispuck.selectedvalue*0.36);
          }
          thispuck.showMenu();
        }else{
          if(thispuck.selectValue(int(e))){
            thispuck.valrotation = int(thispuck.selectedvalue*0.36);
          }
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
