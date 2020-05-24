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

//void lerpColorRing(color ca, color cb, float x, float y, float r, float sweight, int angstart, int angend){
//  int angdiff = angend - angstart;
//  strokeWeight(sweight);
//  for(int a = angstart; a < angend; a++){
//    stroke(lerpColor(ca,cb,float(a-angstart)/float(angdiff))); //val ring color
//    arc(x,y,r,r,radians(angstart), radians(angstart + a));
//  }
//}
