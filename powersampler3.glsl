uniform sampler2D texture;
uniform sampler2D texture2;
uniform vec2 limits;

void main()
{   

   vec2 uv = gl_TexCoord[0].xy;

   vec2 uv2 = vec2(uv.x,1.0-uv.y);

   vec4 tc = texture2D(texture2, uv2);
   vec4 t0 = texture2D(texture, uv);


   float scaler1 = 1.0-smoothstep(limits.x,limits.y,uv.y);

   gl_FragColor = vec4(mix(t0.rgb , tc.rgb , scaler1), 1.0);
   //gl_FragColor = vec4(tc.rgb ,  1.0);

}