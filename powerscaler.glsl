uniform sampler2D texture;
uniform vec2 resol;

void main()
{   

   vec2 uv = gl_TexCoord[0].xy;

   uv = uv*resol + 0.5;

   vec2 i = floor(uv);
   vec2 f = uv - i;
   f = f*f*f*(f*(f*6.0-15.0)+10.0);
   uv = i + f;
   uv = (uv - 0.5)/resol;

   gl_FragColor = gl_Color*texture2D(texture, uv);

}