boolean pointincircle(float x, float y, float cx, float cy, float cr){
  if(dist(x,y,cx,cy) > cr/2){
    return false;
  }else{
    return true;
  }
}

boolean pointinrect(float x, float y, float rx, float ry, float rw, float rh){
  if(x < rx+rw/2 && x > rx-rw/2 && y < ry+rh/2 && y > ry-rh/2){
    return true;
  }else{
    return false;
  }
}

boolean circleincircle(float cx, float cy, float cr, float ox, float oy, float or){
  if(dist(cx,cy,ox,oy) > (cr + or)/2){
    return false;
  }else{
    return true;
  }
}

//boolean circleinrect(float cx, float cy, float cr, float rx, float ry, float rw, float rh){
//  float testX = cx;
//  float testY = cy;

//  // which edge is closest?
//  if (cx < rx-rw/2){
//    testX = rx-rw/2;            // test left edge
//  }else if (cx > rx+rw/2){
//    testX = rx+rw/2;   // right edge
//  }
//  if (cy < ry-rh/2){
//    testY = ry-rh/2;            // top edge
//  }else if (cy > ry+rh/2){
//    testY = ry+rh/2;   // bottom edge
//  }
//  // get distance from closest edges
//  float distX = cx-testX;
//  float distY = cy-testY;
//  float distance = sqrt((distX*distX) + (distY*distY));

//  // if the distance is less than the radius, collision!
//  if (distance <= cr/2) {
//    return true;
//  }
//  return false;
//}
