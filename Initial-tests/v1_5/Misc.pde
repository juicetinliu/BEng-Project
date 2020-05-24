float limdegrees(float indegrees){
  if(indegrees > 360){
    return indegrees % 360;
  }else if(indegrees < 0){
      return indegrees % 360 + 360;
  }else{
    return indegrees;
  }
}

float limradians(float inrads){
  if(inrads > 2*PI){
    return inrads % (2*PI);
  }else if(inrads < 0){
      return inrads % (2*PI) + 2*PI;
  }else{
    return inrads;
  }
}

boolean mspassed(int starttime, int interval){
  return millis() > starttime + interval;
}

PVector limtoscreen(PVector limvect){
  return limvect.set(max(0,min(width,limvect.x)),max(0,min(height*0.8,limvect.y)));
  
}
