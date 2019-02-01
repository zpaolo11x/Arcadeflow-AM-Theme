uniform sampler2D texture;
uniform sampler2D textureglow;
uniform vec2 limits;
uniform float vertical;
uniform float cropsnap;

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
vec2 uv2 = vec2(0,0);
vec2 uv3 = vec2(0,0);

uv2 = gl_TexCoord[0].xy;

if (cropsnap == 0.0) {
   if (vertical == 1.0){
      uv = uv2.xy;
      uv3.x = - 0.5/6.0 + uv2.x*4.0/3.5;
      uv3.y =  1.0 - uv2.y;
   }
   else {
      uv = uv2.yx;
      uv3.x = uv2.x;
      uv3.y =  +0.5/6.0 +1.0- uv2.y*4.0/3.5;
   }
}

if (cropsnap == 1.0) {
   if (vertical == 1.0){
      uv = uv2.xy;
      uv3.x = uv2.x;
      uv3.y =  (1.0-uv2.y)*3.0/4.0 + 1.0/8.0;
   }
   else {
      uv = uv2.yx;
      uv3.x = uv2.x*3.0/4.0 + 1.0/8.0;
      uv3.y = 1.0-uv2.y;
   }
}


vec4 t0 = texture2D(textureglow, uv);

vec4 tc = texture2D(texture, uv3);

vec3 hue = rgb2hsv (tc.rgb);


vec3 tch2 = hsv2rgb (vec3(hue.x,(2.0*hue.z-hue.z*hue.z)*(2.0*hue.y-hue.y*hue.y)*(1.0-t0.a),1.0));


gl_FragColor = vec4(tch2.rgb , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

}