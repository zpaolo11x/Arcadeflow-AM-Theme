uniform sampler2D texture;
uniform vec2 limits;
uniform float level;

void main()
{   

   vec2 uv = gl_TexCoord[0].xy;
  
   vec4 tc = vec4(0.0);
   vec4 t0 = texture2D(texture, uv);


float stepz = 1.0/(2.0*level);

for (float ix = stepz ; ix < 1.0  ; ix += 2.0*stepz){
   for (float iy = stepz ; iy < 0.5 ; iy += 2.0*stepz){
      tc += texture2D(texture, vec2 (ix,iy));
   }
}



   float scaler1 = 1.0-smoothstep(limits.x,limits.y,uv.y);

   gl_FragColor = vec4(mix(t0.rgb , tc.rgb/(0.5*level*level) , scaler1*0.95), 1.0);

}