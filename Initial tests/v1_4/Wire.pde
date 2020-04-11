class Wire{
  int id;
  float x, y;
  ArrayList<Puck> connectedPucks = new ArrayList<Puck>();
  
  Wire(int id, float x, float y, ArrayList<Puck> connected){
    this.id = id;
    this.x = x;
    this.y = y;
    this.connectedPucks = connected;
  }
  
  void display(){
    updatexy();
    //ellipse(x,y,size,size);
    
  }
  
  void updatexy(){
    
  }
  
  void run(){
    
  }

  //float 
  
}
