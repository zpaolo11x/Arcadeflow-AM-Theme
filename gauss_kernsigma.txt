uniform sampler2D source;
uniform vec2 kernelZ;
uniform vec2 offsetFactor;

void main() {
    vec2 sourceCoordinates = gl_TexCoord[0].xy;
    vec4 color = vec4(0.0);
    
    float kernelStart = -(kernelZ.x - 1.0)*0.5;
    float kernelSigma = kernelZ.y;
    float invkernelSigma = 1.0 / kernelSigma;
    float invkernelSigmasq = invkernelSigma * invkernelSigma;
    float kersum = 0.0;
    float kerval = 0.0;

    for (float i = kernelStart ; i <= - kernelStart ; i++) {
        kerval = (invkernelSigma*0.282094792)*exp(-0.5*i*i*invkernelSigmasq);
        color += texture2D(source, sourceCoordinates + i * offsetFactor) * kerval;
        kersum += kerval;
    }
    
    gl_FragColor = color/kersum;
}