uniform sampler2D texture;

void main()
{   

vec2 uv = gl_TexCoord[0].xy;
vec4 t0 = texture2D(texture, uv);

gl_FragColor = vec4(vec3(gl_Color.x) , gl_Color.a*(1.0 - t0.x));

}