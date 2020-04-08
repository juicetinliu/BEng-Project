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
