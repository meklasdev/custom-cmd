// Bloom/Glow Shader
// Adds a subtle glow to bright pixels

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    
    // Simple 4-tap blur for bloom check
    float blurSize = 0.002;
    float4 sum = color;
    sum += shaderTexture.Sample(samplerState, tex + float2(-blurSize, 0));
    sum += shaderTexture.Sample(samplerState, tex + float2(blurSize, 0));
    sum += shaderTexture.Sample(samplerState, tex + float2(0, -blurSize));
    sum += shaderTexture.Sample(samplerState, tex + float2(0, blurSize));
    sum /= 5.0;
    
    // Mix original with blurred version for "glow"
    return lerp(color, sum, 0.4) * 1.2; 
}
