class nood{
  float x, y;
  float size;
  float basex, basey;
  boolean selected;
  float mouseoffx;
  float mouseoffy;
  boolean stucktoblock;

  
  nood(float x, float y, float size, float basex, float basey){
    this.x = x;
    this.y = y;
    this.size = size;
    this.basex = basex;
    this.basey = basey;
    this.selected = false;
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.stucktoblock = true;
  }
  
  void display(){
    stroke(255);
    strokeWeight(1);
    line(x,y,basex,basey);
    
    if(selected){
      fill(255);
    }else{
      if(pointincircle(mouseX,mouseY,x,y,size)){
        fill(255,128);
      }else{
        fill(0);
      }
    }
    ellipse(x, y, size,size);
  }
  
  void mouseMove(){
    //if(mousePressed){
      x = mouseX - mouseoffx;
      y = mouseY - mouseoffy;
    //}
  }
  
}
