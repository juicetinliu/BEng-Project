float bezierLength(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2, float precision) {
  if (precision <= 0 || precision >= 1) return -1;

  float l = 0;
  float i = 0;
  while (i+precision <= 1) {
    float xPos1 = bezierPoint(x1, cx1, cx2, x2, i);
    float xPos2 = bezierPoint(x1, cx1, cx2, x2, i+precision);
    float yPos1 = bezierPoint(y1, cy1, cy2, y2, i);
    float yPos2 = bezierPoint(y1, cy1, cy2, y2, i+precision);
    l += dist(xPos1, yPos1, xPos2, yPos2);
    //println(i+precision);
    i += precision;
  }

  return l;
}

float limdegrees(float indegrees){ //keeps input angle between 0 - 360
  if(indegrees > 360){
    return indegrees % 360;
  }else if(indegrees < 0){
      return indegrees % 360 + 360;
  }else{
    return indegrees;
  }
}

float sigmoid(float input){
  return 2/(1+exp(-input)) - 1;
}

float limradians(float inrads){ //keeps input angle between 0 - 2PI
  if(inrads > 2*PI){
    return inrads % (2*PI);
  }else if(inrads < 0){
      return inrads % (2*PI) + 2*PI;
  }else{
    return inrads;
  }
}

boolean withinradians(float inrad, float lowrad, float hirad){ // returns true if inrad is within angle bounds (lowrad is the lower bound; hirad is the higher bound)
  if(lowrad > hirad){
    return (inrad > lowrad && inrad <= 2*PI) || (inrad >= 0 && inrad < hirad);
  }else{
    return inrad > lowrad && inrad < hirad;
  }
}

float maxangdiff(float radone, float radtwo){ //returns larger of the two possible difference between two vector angles
  float diff = abs(radone - radtwo);
  return (diff < PI) ? 2 * PI - diff : diff;
}

float minangdiff(float radone, float radtwo){ //returns smaller of the two possible difference between two vector angles
  float diff = abs(radone - radtwo);
  return (diff < PI) ? diff : 2 * PI - diff;
}

boolean mspassed(int starttime, int interval){
  return millis() > starttime + interval;
}

PVector limtoscreen(PVector limvect){
  return limvect.set(max(0,min(width,limvect.x)),max(0,min(height*0.8,limvect.y)));
  
}

String prefixCodetoNGCode(char prefix){
  switch(prefix){
    case 'T': //tera
      return "T";
    case 'G': //giga
      return "G";
    case 'M': //mega
      return "Meg";
    case 'k': //kilo
      return "K";
    case 'N': //normal??
      return "";
    case 'm': //milli
      return "m";
    case 'µ': //micro
      return "u";
    case 'n': //nano 
      return "n";
    case 'p': //pico 
      return "p";
    default:
      return "";
  }
}

String intCodetoNGCode(int intCode){
  switch(intCode){
    case 4: //tera
      return "T";
    case 3: //giga
      return "G";
    case 2: //mega
      return "Meg";
    case 1: //kilo
      return "K";
    case 0: //normal??
      return "";
    case -1: //milli
      return "m";
    case -2: //micro
      return "u";
    case -3: //nano 
      return "n";
    case -4: //pico 
      return "p";
    default:
      return "";
  }
}

int prefixCodetoInt(char prefix){
  switch(prefix){
    case 'T': //tera
      return 4;
    case 'G': //giga
      return 3;
    case 'M': //mega
      return 2;
    case 'k': //kilo
      return 1;
    case 'N': //normal??
      return 0;
    case 'm': //milli
      return -1;
    case 'µ': //micro
      return -2;
    case 'n': //nano 
      return -3;
    case 'p': //pico 
      return -4;
    default:
      return 0;
  }
}
//1234567890pnµmkMGTFHVΩ
char intCodetoPrefix(int intCode){
  switch(intCode){
    case 4:
      return 'T'; //tera
    case 3:
      return 'G'; //giga
    case 2:
      return 'M'; //mega
    case 1:
      return 'k'; //kilo
    case 0:
      return '\0'; //normal??
    case -1:
      return 'm'; //milli
    case -2:
      return 'µ'; //micro
    case -3:
      return 'n'; //nano 
    case -4:
      return 'p'; //pico 
    default:
      return 'N';
  }
}

color intCodetoColour(int intCode, int alpha){
  switch(intCode){
    case 4: //tera
      return color(255,alpha);
    case 3: //giga
      return color(150,alpha);
    case 2: //mega
      return color(130,0,255,alpha);
    case 1: //kilo
      return color(0,150,255,alpha);
    case 0:  //normal??
      return color(20,255,0,alpha); //green
    case -1: //milli
      return color(255,240,0,alpha); //yellow
    case -2: //micro
      return color(255,150,0,alpha); //orange
    case -3: //nano 
      return color(255,0,0,alpha); //red
    case -4: //pico 
      return color(180,120,30,alpha); //brown
    default:
      return color(0); //black
  }
  
}

String floatToPreInt(float in, int count){
  if(in == 0){
    return "0";
  }
  if(abs(in) < 1){
    return floatToPreInt(in * 1000, count - 1);
  }else if(abs(in) > 999){
    return floatToPreInt(in / 1000, count + 1);
  }else{
    return nf(in,0,3).substring(0,4) + intCodetoPrefix(count);
  }
}

//void lerpColorRing(color ca, color cb, float x, float y, float r, float sweight, int angstart, int angend){
//  int angdiff = angend - angstart;
//  strokeWeight(sweight);
//  for(int a = angstart; a < angend; a++){
//    stroke(lerpColor(ca,cb,float(a-angstart)/float(angdiff))); //val ring color
//    arc(x,y,r,r,radians(angstart), radians(angstart + a));
//  }
//}
