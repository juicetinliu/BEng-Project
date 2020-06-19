#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec4 pos;

uniform float ratio;
uniform vec2 cirxy;

void main() {
//  float pct = 0.0;
//  pct = distance(st,vec2(0.5));
//  vec3 color = vec3(pct);
    vec2 newcirxy = (cirxy-0.5)*2.0;
    newcirxy.x = newcirxy.x * ratio;
    vec2 newposxy = pos.xy;
    newposxy.x = newposxy.x * ratio;
    float dist = max(1.0 - distance(newposxy,newcirxy),0.0);
    gl_FragColor = vec4(vertColor.rgb,vertColor.a*dist);
}
