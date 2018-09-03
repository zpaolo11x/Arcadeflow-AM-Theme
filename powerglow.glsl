uniform sampler2D texture;
uniform sampler2D textureglow;
uniform vec2 limits;
uniform float level;
uniform float vertical;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{   

vec2 uv = vec2(0.0);

if (vertical == 1.0){
    uv = gl_TexCoord[0].xy;
}
else {
     uv = gl_TexCoord[0].yx;
}

   vec4 tc = vec4(0.0);
   vec4 t0 = texture2D(textureglow, uv);


float stepz = 1.0/(2.0*level);
float sat0 = 1.0;

for (float ix = stepz ; ix < 1.0  ; ix += 2.0*stepz){
   for (float iy = stepz ; iy < 0.5 ; iy += 2.0*stepz){
      tc += texture2D(texture, vec2 (ix,iy));
   }
}

tc = tc/(0.5*level*level);
vec3 hue = rgb2hsv (tc.rgb);

if (hue.y < 0.1) {
    sat0 = 0.0;
}

vec3 tch = hsv2rgb (vec3(hue.x,sat0*(0.50-0.5*t0.a*t0.a),0.7+sat0*0.3));


   gl_FragColor = vec4(tch , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

}