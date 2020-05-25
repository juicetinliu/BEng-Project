void drawBackground(){
  if(circuitRun){
    background(50);
  }else if(removemode){
    background(100,0,0);
  }else if(graphmode){
    background(0,0,100);
  }else{
    background(0);
  }
}

void showSettingsPanel(){
  fill(0);
  stroke(255);
  strokeWeight(3);
  rect(width/2,height/2,width*0.8,height*0.8);  
  
  fill(255);
  textSize(20);
  textAlign(CENTER);
  text("Settings", width/2, height*0.15);
  
  textSize(16);
  textAlign(LEFT, CENTER);
  text("Scroll Sensitivity", width*0.15,height*0.2);
  
  text("Shake Sensitivity", width*0.15,height*0.3);
  
  //text("Disc Size", width*0.15,height*0.4);
  
  //text("Disc Rotation", width*0.15, height*0.5); //segmented, natural 
  
  
  
  textAlign(CENTER);
  text("Save", width/2, height*0.85);
  
  textSize(12);
  for(Slider thisslider:sliders){
    thisslider.display();
  }
  
  textSize(12);
}
