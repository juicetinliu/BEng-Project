class Circle{
  int x, y, r;
  
  Circle(int x, int y, int r){
    this.x = x;
    this.y = y;
    this.r = r;
  }
  
  void display(){
    noFill();
    stroke(255,0,0);
    ellipse(x,y,r*2,r*2);
  }
  
}
