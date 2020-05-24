class Graph{
  float x, y;
  float[] values = new float[100];
  int novalues;
  float minval, maxval;
  int interval;
  
  Graph(int novalues, int interval){
    this.x = 0;
    this.y = 0;
    this.novalues = novalues;
    this.minval = 0;
    this.maxval = 0;
    this.interval = interval;
    resetValues();
  }
  
  void show(float w, float h){
    rectMode(CENTER);
    pushMatrix();
    translate(x,y);
    
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(0,0,w,h);
    
    popMatrix();
  }
  
  void move(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void addValue(float val){
    for(int i = values.length - 1; i > 0; i--){
      values[i] = values[i-1];
    }
    values[0] = val;
  }
  
  void resetValues(){
    for(int i = 0; i < values.length; i++){
      values[i] = 0;
    }
  }
  
  void updateMax(float max){
    this.maxval = max;
  }
  
  void updateMin(float min){
    this.minval = min;
  }
}
