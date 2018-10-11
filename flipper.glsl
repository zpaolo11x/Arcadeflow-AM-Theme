uniform sampler2D texture;
uniform float rotation;

void main()
{   

   vec2 uv = gl_TexCoord[0].xy;
   vec4 col = vec4(0.0);

   if (rotation == 0.0){
      col = texture2D(texture, uv.xy);
   }

   else if (rotation == 1.0){
      col = texture2D(texture, vec2(1.0-uv.y,uv.x));
   }
   
   else if (rotation == 2.0){
      col = texture2D(texture, vec2(1.0-uv.x,1.0-uv.y));
   }

   else if (rotation == 3.0){
      col = texture2D(texture, vec2(uv.y,1.0-uv.x));
   }

   gl_FragColor = vec4(col.rgb , col.a);

}