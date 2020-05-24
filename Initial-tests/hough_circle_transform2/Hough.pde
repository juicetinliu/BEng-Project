//class Hough{
//  int x, y, r;
//  float vote;
  
//  Hough(int x, int y, int r, float vote){
//    this.x = x;
//    this.y = y;
//    this.r = r;
//    this.vote = vote;
//  }
  
//  void addVote(float amount){
//    vote += amount;
//  }
  
//  void reset(){
//    vote = 0;
//  }
  
//  public float getVote(){
//    return vote;
//  }
  
//  void display(){
//    noFill();
//    stroke(255,0,0);
//    ellipse(x,y,r*2,r*2);
//  }
//}

//void resetHoughs(ArrayList<Hough> houghIn){
//  for(Hough thish:houghIn){
//    thish.reset();
//  }
//}

//ArrayList<Hough> sortHoughs(ArrayList<Hough> houghIn){
//  ArrayList<Hough> houghOut = new ArrayList<Hough>();
  
//  houghOut.addAll(houghIn);
  
//  houghOut.sort(new Comparator<Hough>() {
//      @Override
//      public int compare(Hough o1, Hough o2) {
//          return Float.compare(o1.getVote(), o2.getVote());
//      }
//  });
//  return houghOut;
//}

//boolean addToHough(ArrayList<Hough> houghIn, int x, int y, int r, float v){
//  for(Hough thish:houghIn){
//    if(thish.x == x && thish.y == y && thish.r == r){
//      thish.addVote(v);
//      return true;
//    }
//  }
//  return false;
//}
