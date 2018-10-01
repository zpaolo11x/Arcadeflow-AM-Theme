uniform sampler2D texture;
uniform vec2 kernelData;
uniform vec2 offsetFactor;

void main() {



   vec2 uv = gl_TexCoord[0].xy;
   vec4 color = vec4(0.0);
    
   float kernelStart = -(kernelData.x - 1.0)*0.5;
   float gaussSigma = kernelData.y;

   float invgaussSigma = 1.0 / gaussSigma;
   float invgaussSigmasq = invgaussSigma * invgaussSigma;
   float weightSum = 0.0;
   float weightVal = 0.0;

   for (float i = kernelStart ; i <= - kernelStart ; i++) {
      for (float j = kernelStart ; j <= - kernelStart ; j++) {
         weightVal = (invgaussSigma*0.282094792)*exp(-0.5*((i*i)+(j*j))*invgaussSigma);
         color += texture2D(texture, uv + vec2(i * offsetFactor.x , j * offsetFactor.y)) * weightVal;
         weightSum += weightVal;
      }
   }
    
    gl_FragColor = color/weightSum;

}