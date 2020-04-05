ArrayList<Puck> pucks = new ArrayList<Puck>();

void setup(){
  size(1200,800);
  //smooth();
  pixelDensity(displayDensity());
  //pucks.add(new Puck(1, width/2,height/2,50));
  //pucks.add(new Puck(2, width/4,height/2,50));
  randomSeed(16);
  pucks.add(new Puck(1, random(width),random(height),100));
  pucks.add(new Puck(2, random(width),random(height),100));
  pucks.add(new Puck(3, random(width),random(height),100));
  pucks.add(new Puck(4, random(width),random(height),100));
  //pucks.add(new puck(3, width*3/4,height/2,50));
  //pucks.add(new puck(4, width/2,height/4,50));
  //pucks.add(new puck(5, width/2,height*3/4,50));

}
void draw(){
  background(0);
  
  fill(255);
  text(frameRate,10,10);
  
  fill(128,100);
  strokeWeight(1);
  stroke(255);
  rectMode(CENTER);
  rect(width/2,height*0.9,width,height*0.2);
  
  for(Puck thispuck:pucks){
    thispuck.display();
    thispuck.run();
  }
  checkAuras(pucks);
  checkPuckSpace(pucks);
}
