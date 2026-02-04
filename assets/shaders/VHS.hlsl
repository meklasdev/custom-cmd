// VHS / Analog Glitch Shader
Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

float rand(float2 co){
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float2 uv = tex;
    
    // Scanline jitter
    float jitter = sin(uv.y * 200.0 + Time * 10.0) * 0.002;
    uv.x += jitter;
    
    float4 color = shaderTexture.Sample(samplerState, uv);
    
    // Color bleed
    float4 colorLeft = shaderTexture.Sample(samplerState, uv + float2(0.002, 0.0));
    color.r = colorLeft.r;
    
    // Noise
    float noise = rand(uv * Time) * 0.1;
    
    return color + noise;
}
