class Graph{
  float x, y;
  float anchorx, anchory;
  color graphColor;
  float w, h;
  float mouseoffx, mouseoffy;
  float[] values = new float[100];
  int novalues;
  float minval, maxval;
  int interval; //MILLISECONDS0
  int type; //0 - VOLTAGE; 1 - CURRENT
  boolean OSCILLOSCOPE;
  boolean selected;
  
  Graph(float x, float y, int novalues, int interval, int type, boolean osc){
    this.x = x;
    this.y = y;
    this.anchorx = x;
    this.anchory = y;
    this.w = width/4;
    this.h = height/4;
    colorMode(HSB, 360, 100, 100);
    this.graphColor = color(random(360),50,100);
    colorMode(RGB, 255, 255, 255);
    this.mouseoffx = 0;
    this.mouseoffy = 0;
    this.novalues = novalues;
    this.minval = -1;
    this.maxval = 1;
    this.interval = interval;
    this.type = type;
    this.selected = false;
    this.OSCILLOSCOPE = osc;
    resetValues();
  }
  
  void show(){
    drawAnchor();
    pushMatrix();
    translate(x,y);
    if(!OSCILLOSCOPE && pointinrect(mouseX,mouseY,x,y,w,h)){
      fill(255,128);
    }else{
      noFill();
    }
    stroke(255);
    strokeWeight(2);
    rect(0,0,w,h);
    
    popMatrix();
    
    drawAxes();
    drawGraph();
  }
  
  void drawAnchor(){
    rectMode(CENTER);
    stroke(graphColor,128);
    strokeWeight(2);
    float mapyanch = map(values[0],minval,maxval,h*0.45,-h*0.45);
    line(x+w*0.45,y+mapyanch,anchorx,anchory);
  }
  
  void drawAxes(){
    pushMatrix();
    translate(x,y);
    noFill();
    stroke(255);
    strokeWeight(2);
    float mapzeroy = map(0,minval,maxval,h*0.45,-h*0.45);
    line(-w*0.45,mapzeroy,w*0.45,mapzeroy);
    line(-w*0.45,h*0.45,-w*0.45,-h*0.45);
    popMatrix();
  }
  
  void drawGraph(){
    pushMatrix();
    translate(x,y);
    //if(type == 0){
    //  stroke(0,200,255);
    //}else{
    //  stroke(255,0,255);
    //}
    stroke(graphColor);
    beginShape();
    for(int i = 0; i < values.length; i++){
      float mapxval = map(i,0,values.length-1,w*0.45,-w*0.45);
      float mapyval = map(values[i],minval,maxval,h*0.45,-h*0.45);
      vertex(mapxval,mapyval);
    }
    endShape();
    popMatrix();
  }
  
  void move(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void setAnchor(float x, float y){
    anchorx = x;
    anchory = y;
  }
  
  void select(){
    selected = true;
    mouseoffx = mouseX - x;
    mouseoffy = mouseY - y;
  }
  
  void mouseMove(){
    x = mouseX - mouseoffx;
    y = mouseY - mouseoffy;
  }
  
  
  void addValue(float val){
    for(int i = values.length - 1; i > 0; i--){
      values[i] = values[i-1];
    }
    values[0] = val;
    
    if(!OSCILLOSCOPE){
      if(val > maxval){
        maxval = val;
      }else if(val < minval){
        minval = val;
      }
    }
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
  
  void run(){
    if(selected && !OSCILLOSCOPE){
      mouseMove();
    }
  }
}

void showGraphs(){
  int osccounter = 0;
  for(Graph thisgraph:graphs){
    thisgraph.run();
    if(thisgraph.OSCILLOSCOPE){
      if(osccounter == 0){
        thisgraph.show();
      }else{
        thisgraph.drawAnchor();
        thisgraph.drawGraph();
      }
      osccounter++;
    }else{
      thisgraph.show();
    }
  }
}

void updateOSCgraphpos(float x, float y){
  for(Graph thisgraph:graphs){
    if(thisgraph.OSCILLOSCOPE){
      thisgraph.move(x,y);
    }
  }
}
