#version 330 core

uniform sampler2D tex;
uniform int type;
uniform vec4 colours[4];

in vec2 Texcoord;

out vec4 FragColor;

void main() {
   if (type == 0) {
      FragColor = vec4(colours[0].rgb/255, colours[0].a/255);
      return;
   } else if (type == 1) {
      //lerp
      /*for (int i = 0; i < 4; i++) {
         if (colours[i] == vec4(0,0,0,0)) {
            break;
         }
      }*/
      
      return;
   } else {
      FragColor = texture(tex, Texcoord);
   }
}
