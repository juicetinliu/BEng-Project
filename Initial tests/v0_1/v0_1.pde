ArrayList<nood> noods = new ArrayList<nood>();
ArrayList<block> blocks = new ArrayList<block>();
void setup(){
  size(600,400);
  //smooth();
  pixelDensity(displayDensity());
  //noods.add(new nood(width/2,height/2,100,0,height/2));
  //noods.add(new nood(width/2,height/2+10,100,0,height/2));
  //noods.add(new nood(width/2,height/2-10,100,0,height/2));
  blocks.add(new block(width/2,height/2,100,50));
  blocks.add(new block(width/2,height/2+100,100,50));
}
void draw(){
  background(0);
  
  fill(255);
  text(frameRate,50,50);
  for(block thisblock:blocks){
    thisblock.display();
    if(thisblock.selected){
      thisblock.mouseMove();
    }
    if(thisblock.nood1.selected){
        thisblock.nood1.mouseMove();
    }else if(thisblock.nood2.selected){
      thisblock.nood2.mouseMove();
    }
  }
}
