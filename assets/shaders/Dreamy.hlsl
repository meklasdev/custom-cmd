// Dreamy / Soft Focus Shader
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
    float4 c = shaderTexture.Sample(samplerState, tex);
    
    // Simple bloom-like soft glow
    float4 glow = shaderTexture.Sample(samplerState, tex + float2(0.002, 0.002))
                + shaderTexture.Sample(samplerState, tex - float2(0.002, 0.002));
    glow *= 0.5;
    
    return c * 0.6 + glow * 0.4 + float4(0.05, 0.02, 0.05, 0.0); // purple tint
}
