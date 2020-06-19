void mousePressed(){
  if(settingsOpen){
    if(mouseButton == LEFT){
      for(Slider thisslider:sliders){
        if(thisslider.clicked()){
          thisslider.select();
          return;
        }
      }
      Button settingsbutton = buttons.get(0);
      if(settingsbutton.clicked()){
        settingsbutton.doAction();
        return;
      }
    }
  }else{
    if(mouseButton == LEFT){
      for(Puck thispuck:pucks){
        if(pointincircle(mouseX,mouseY,thispuck.x,thispuck.y,thispuck.size)){
          if(removemode){
            thispuck.removeConnections();
            thispuck.removeGraph();
            pucks.remove(thispuck);
            removemode = false;
          }else if(graphmode){
            if(thispuck.selectedComponent.id != 8){ //IF IT ISN'T AN OSCILLOSCOPE
              Graph newGraph = new Graph(thispuck.x,thispuck.y,100,100,1, false);
              if(!thispuck.addGraph(newGraph)){ //if addgraph fails(already contains graph) then remove graph
                thispuck.removeGraph();
              }
              graphmode = false;
            }
          }else{
            thispuck.select();
          }
          return;
        }
      }
      for(Wire thiswire:wires){
        if(pointincircle(mouseX,mouseY,thiswire.x,thiswire.y,thiswire.size)){
          if(graphmode){
            Graph newGraph = new Graph(thiswire.x,thiswire.y,100,100,0, false);
            if(!thiswire.addGraph(newGraph)){ //if addgraph fails(already contains graph) then remove graph
              thiswire.removeGraph();
            }
            graphmode = false;
          }
          return;
        }
      }
      for(Graph thisgraph:graphs){
        if(!thisgraph.OSCILLOSCOPE){
          if(pointinrect(mouseX,mouseY,thisgraph.x,thisgraph.y,thisgraph.w,thisgraph.h)){
            thisgraph.select();
            return;
          }
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
}

void mouseReleased(){
  for(Slider thisslider:sliders){
    thisslider.selected = false;
  }
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
