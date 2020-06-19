uniform mat4 transform;

attribute vec4 position;
attribute vec4 color;

varying vec4 vertColor;
varying vec4 pos;

void main() {
  gl_Position = transform * position;
  pos = gl_Position;
  vertColor = color;
}

