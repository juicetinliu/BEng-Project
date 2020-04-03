void mousePressed(){
  boolean oneselected = false;
  //for(nood thisnood:noods){
  //  if(pointincircle(mouseX,mouseY,thisnood.x,thisnood.y,thisnood.size) && !oneselected){
  //    thisnood.selected = true;
  //    thisnood.mouseoffx = mouseX - thisnood.x;
  //    thisnood.mouseoffy = mouseY - thisnood.y;
  //    oneselected = true;
  //  }
  //}
  
  for(block thisblock:blocks){
    if(pointinrect(mouseX,mouseY,thisblock.x,thisblock.y,thisblock.w,thisblock.h) && !oneselected){
      thisblock.selected = true;
      thisblock.mouseoffx = mouseX - thisblock.x;
      thisblock.mouseoffy = mouseY - thisblock.y;
      oneselected = true;
    }
    nood nood1 = thisblock.nood1;
    nood nood2 = thisblock.nood2;
    if(pointincircle(mouseX,mouseY,nood1.x,nood1.y,nood1.size) && !oneselected){
      nood1.selected = true;
      nood1.stucktoblock = false;
      nood1.mouseoffx = mouseX - nood1.x;
      nood1.mouseoffy = mouseY - nood1.y;
      oneselected = true;
    }else if(pointincircle(mouseX,mouseY,nood2.x,nood2.y,nood2.size) && !oneselected){
      nood2.selected = true;
      nood2.stucktoblock = false;
      nood2.mouseoffx = mouseX - nood2.x;
      nood2.mouseoffy = mouseY - nood2.y;
      oneselected = true;
    }
  }
  
}

void mouseDragged(){
  
}

void mouseReleased(){
  for(nood thisnood:noods){
    thisnood.selected = false;
  }
  for(block thisblock:blocks){
    thisblock.selected = false;
    thisblock.nood1.selected = false;
    thisblock.nood2.selected = false;
  } 
}

boolean pointincircle(float x, float y, float cx, float cy, float cr){
  if(dist(x,y,cx,cy) > cr/2){
    return false;
  }else{
    return true;
  }
}

boolean pointinrect(float x, float y, float rx, float ry, float rw, float rh){
  if(x < rx+rw/2 && x > rx-rw/2 && y < ry+rh/2 && y > ry-rh/2){
    return true;
  }else{
    return false;
  }
}
