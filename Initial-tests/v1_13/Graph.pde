class Graph{
  float x, y;
  float anchorx, anchory;
  color graphColor;
  float w, h;
  float mouseoffx, mouseoffy;
  float[] values = new float[100];
  IntList times = new IntList();
  int novalues;
  float minval, maxval;
  float minpoint = 0, maxpoint = 0;
  String rangetext = "1V";
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
  
  void show(int osccounter){
    drawAnchor();
    pushMatrix();
    translate(x,y);
    if(OSCILLOSCOPE){
      fill(graphColor);
      textAlign(LEFT);
      text("Src " + (osccounter + 1) + ":" + rangetext, -w*0.5 + (osccounter*w/4), -h*0.55);
    }
    if(!OSCILLOSCOPE && pointinrect(mouseX,mouseY,x,y,w,h)){
      fill(255,128);
    }else{
      noFill();
    }
    stroke(255);
    strokeWeight(2);
    rect(0,0,w,h);
    rect(0,0,w*0.9,h*0.8);
    popMatrix();
    
    drawAxes();
    drawGraph(osccounter);
  }
  
  void drawAnchor(){
    rectMode(CENTER);
    stroke(graphColor,128);
    strokeWeight(2);
    float mapyanch = map(min(maxval,max(minval,values[0])),minval,maxval,h*0.4,-h*0.4);
    line(x+w*0.45,y+mapyanch,anchorx,anchory);
  }
  
  void drawAxes(){
    pushMatrix();
    translate(x,y);
    noFill();
    stroke(255);
    strokeWeight(2);
    float mapzeroy = map(0,minval,maxval,h*0.4,-h*0.4);
    line(-w*0.45,mapzeroy,w*0.45,mapzeroy);
    line(-w*0.45,h*0.4,-w*0.45,-h*0.4);
    popMatrix();
  }
  
  void drawGraph(int osccounter){
    pushMatrix();
    translate(x,y);
    if(OSCILLOSCOPE){
      fill(graphColor);
      textAlign(LEFT);
      text("Src " + (osccounter + 1) + ":" + rangetext, -w*0.5 + (osccounter*w/4), -h*0.55);
      textAlign(LEFT,CENTER);
      text(rangetext,-w*0.475 + (osccounter*w/4),-h*0.45);
      text("-" + rangetext,-w*0.475 + (osccounter*w/4),h*0.45);
    }
    //if(type == 0){
    //  stroke(0,200,255);
    //}else{
    //  stroke(255,0,255);
    //}
    noFill();
    strokeWeight(2);
    stroke(graphColor);
    beginShape();
    for(int i = 0; i < values.length; i++){
      float mapxval = map(i,0,values.length-1,w*0.45,-w*0.45);
      float mapyval = map(min(maxval,max(minval,values[i])),minval,maxval,h*0.4,-h*0.4);
      vertex(mapxval,mapyval);
    }
    endShape();
    popMatrix();
  }
  
  void drawMaxMin(){
    pushMatrix();
    translate(x,y);
    textAlign(CENTER,CENTER);
    if(maxpoint != 0){
      strokeWeight(1);
      stroke(graphColor,128);
      float maxpointy = min(h*0.4,max(-h*0.4,map(maxpoint,minval,maxval,h*0.4,-h*0.4)));
      line(-w*0.45,maxpointy,-w*0.05,maxpointy);
      line(w*0.45,maxpointy,w*0.05,maxpointy);
      fill(graphColor);
      
      text(floatToPreInt(maxpoint,0) + "V",0,maxpointy-h*0.05);
    }
    if(minpoint != 0){
      strokeWeight(1);
      stroke(graphColor,128);
      float minpointy = min(h*0.4,max(-h*0.4,map(minpoint,minval,maxval,h*0.4,-h*0.4)));
      line(-w*0.45,minpointy,-w*0.05,minpointy);
      line(w*0.45,minpointy,w*0.05,minpointy);
      fill(graphColor);

      text(floatToPreInt(minpoint,0) + "V",0,minpointy+h*0.05);
    }
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
    
    //if(!OSCILLOSCOPE){
    //  if(val > maxval){
    //    maxval = val;
    //  }else if(val < minval){
    //    minval = val;
    //  }
    //}
    maxpoint = max(values);
    minpoint = min(values);
  }
  
  void resetValues(){
    for(int i = 0; i < values.length; i++){
      values[i] = 0;
    }
    maxpoint = 0;
    minpoint = 0;
  }
  
  void setMaxMin(float range, String rangetext){
    this.maxval = range;
    this.minval = -range;
    this.rangetext = rangetext;
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
        thisgraph.show(osccounter);
      }else{
        thisgraph.drawAnchor();
        thisgraph.drawGraph(osccounter);
      }
      osccounter++;
    }else{
      thisgraph.show(0);
    }
    if(osccounter == 1){
      graphs.get(0).drawMaxMin();
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
