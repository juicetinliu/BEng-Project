void mousePressed(){
  if(mouseButton == LEFT){
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
        if(removemode){
          thispuck.removeConnections();
          if(thispuck.puckGraph != null){
            graphs.remove(thispuck.puckGraph);
            thispuck.puckGraph = null;
          }
          pucks.remove(thispuck);
          removemode = false;
        }else if(graphmode){
          if(thispuck.puckGraph == null){
            Graph newGraph = new Graph(thispuck.x,thispuck.y,100,100,1);
            thispuck.addGraph(newGraph);
            graphs.add(newGraph);
          }else{
            graphs.remove(thispuck.puckGraph);
            thispuck.puckGraph = null;
          }
          graphmode = false;
        }else{
          thispuck.select();
        }
        return;
      }
    }
    for(Wire thiswire:wires){
      if(pointincircle(mouseX,mouseY,thiswire.x,thiswire.y,thiswire.size)){
        if(graphmode){
          if(thiswire.wireGraph == null){
            Graph newGraph = new Graph(thiswire.x,thiswire.y,100,100,0);
            thiswire.addGraph(newGraph);
            graphs.add(newGraph);
          }else{
            graphs.remove(thiswire.wireGraph);
            thiswire.wireGraph = null;
          }
          graphmode = false;
        }
        return;
      }
    }
    for(Graph thisgraph:graphs){
      if(pointinrect(mouseX,mouseY,thisgraph.x,thisgraph.y,thisgraph.w,thisgraph.h)){
        thisgraph.select();
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
    if(circuitRun) return;
    for(Puck thispuck:pucks){
      if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
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
  for(Graph thisgraph:graphs){
    thisgraph.selected = false;
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
