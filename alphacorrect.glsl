uniform sampler2D texture;
uniform float maincolor;

void main()
{   

vec2 uv = gl_TexCoord[0].xy;
vec4 t0 = texture2D(texture, uv);

gl_FragColor = vec4(vec3(gl_Color.x) , gl_Color.a*t0.a);

}