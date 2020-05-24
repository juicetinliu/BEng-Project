class block{
  float x, y;
  float w, h;
  ArrayList<nood> blocknoods = new ArrayList<nood>();
  nood nood1;
  nood nood2;
  boolean selected;
  float mouseoffx;
  float mouseoffy;

  block(float x, float y, float w, float h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.selected = false;
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    //blocknoods.add(new nood(x+w/2,y,10,0,0));
    //blocknoods.add(new nood(x-w/2,y,10,0,0));
    //noods.addAll(blocknoods);
    nood1 = new nood(x+w/2,y,10,x+w/2,y);
    nood2 = new nood(x-w/2,y,10,x-w/2,y);
  }
  
  void display(){
    stroke(255);
    strokeWeight(1);
    //line(x,y,basex,basey);
    if(selected){
      fill(255);
    }else{
      if(pointinrect(mouseX,mouseY,x,y,w,h)){
        fill(255,128);
      }else{
        fill(0);
      }
    }
    rectMode(CENTER);
    rect(x, y, w, h);
    //for(nood thisnood:blocknoods){
    //  thisnood.display();
    //}
    nood1.display();
    nood2.display();
  }
  
  void mouseMove(){
    //if(mousePressed){
      x = mouseX - mouseoffx;
      y = mouseY - mouseoffy;
      if(nood1.stucktoblock){
        nood1.x = x+w/2;
        nood1.y = y;
      }
      if(nood2.stucktoblock){
        nood2.x = x-w/2;
        nood2.y = y;
      }
      nood1.basex = x+w/2;
      nood1.basey = y;
      nood2.basex = x-w/2;
      nood2.basey = y;
    //}
  }
  
}
