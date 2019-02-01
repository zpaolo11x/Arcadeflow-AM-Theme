uniform sampler2D texture;
uniform sampler2D textureglow;
uniform vec2 limits;
//uniform float level;
uniform float vertical;
uniform float cropsnap;

vec3 hsl2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

vec3 rgb2hsl( in vec3 c ){
  float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );

	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;
        
        //s = l < .05 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) ); Original
		s = l < .0 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
        
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}

		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec3( h, s, l );
}



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

float sat0 = 1.0;

vec4 tc = texture2D(texture, uv3);

vec3 hue = rgb2hsv (tc.rgb);


if (hue.z < 0.1) {
    sat0 = 0.0;
}

//vec3 tch = hsv2rgb (vec3(hue.x,sat0*(0.50-0.5*t0.a*t0.a),0.7+sat0*0.3));
//vec3 tch = hsv2rgb (vec3(hue.x,1.0-t0.a*1.1,1.0));

vec3 hsl = rgb2hsl(tc.rgb);
vec3 tch = hsv2rgb (vec3(hue.x,sat0*(0.50-0.5*t0.a*t0.a),0.7+sat0*0.3));
//vec3 tch2 = hsv2rgb (vec3(hue.x,(0.50-0.5*t0.a*t0.a),0.7+hue.z*0.3));
//NICE! vec3 tch2 = hsv2rgb (vec3(hue.x,hue.y*t0.a,0.7+hue.z*0.3));

// BELLA SATURA vec3 tch2 = hsv2rgb (vec3(hue.x,hue.y*(1.0-t0.a),1.0));
// BELLA CHIARA vec3 tch2 = hsv2rgb (vec3(hue.x,hue.y*(1.0-t0.a*t0.a),1.0));

// BELLA DAVVERO vec3 tch2 = hsv2rgb (vec3(hue.x,(2.0*hue.z-hue.z*hue.z)*(2.0*hue.y-hue.y*hue.y)*(1.0-t0.a),1.0));

vec3 tch2 = hsv2rgb (vec3(hue.x,(2.0*hue.z-hue.z*hue.z)*(2.0*hue.y-hue.y*hue.y)*(1.0-t0.a),1.0));

vec3 tchx2 = mix(tch2.rgb,vec3(1.0,1.0,1.0),smoothstep(0.0,1.00,t0.a));

vec3 tc2 = hsl2rgb(vec3(hsl.x , hsl.y*2.0 , 0.5+t0.a*t0.a*0.5));


vec3 tc3 = hsl2rgb(vec3(hsl.x , 2.0*hsl.y-hsl.y*hsl.y , 0.75+(1.0-t0.a)*0.25));
//vec3 tc4 = hsl2rgb(vec3(hsl.x , 2.0*hsl.y-hsl.y*hsl.y , 0.5+0.5*(1.0-t0.a)));
vec3 tc4 = hsl2rgb(vec3(hsl.x , 2.0*hsl.y-hsl.y*hsl.y , 0.65+0.35*smoothstep(1.0,0.0,t0.a)));

vec3 tcx = mix(tc3.rgb,vec3(1.0),t0.a*t0.a*t0.a);
vec3 tcx2 = mix(tc4.rgb,vec3(1.0),t0.a*t0.a*t0.a);



 //  gl_FragColor = vec4(tch , 1.0+0.0*gl_Color.a*((t0.a*t0.a+t0.a)/2.0));
//gl_FragColor = vec4(tch.rgb , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

//gl_FragColor = vec4(mix(tc2.rgb,t0.rgb,t0.a*t0.a) , gl_Color.a*t0.a);

// CURRENT STRONG HALO
//gl_FragColor = vec4(tc2.rgb , gl_Color.a*t0.a);

// SMALLER HALO    
// gl_FragColor = vec4(tc2.rgb , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

// OLD LAYOUTS   
// gl_FragColor = vec4(tch , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

// NEW TEST EXTRALIGHT
// gl_FragColor = vec4(mix(tc.rgb,tc3.rgb,uv.y > 0.5 ? 1.0 : 0.0) , t0.a);

// NEW TEST EXTRALIGHT WHITER
// gl_FragColor = vec4(mix(tc.rgb,tcx.rgb,uv.y > 0.5 ? 1.0 : 0.0) , t0.a);

float alphaout = ((t0.a*t0.a+t0.a)/2.0);

//gl_FragColor = vec4(mix(tcx.rgb,tcx2.rgb,uv.y > 0.5 ? 1.0 : 0.0) , t0.a);

gl_FragColor = vec4(tch2.rgb , gl_Color.a*((t0.a*t0.a+t0.a)/2.0));

// PER ORA TCX SEMBRA IL MIGLIORE
}