// High Contrast / Crunch Shader
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
    float3 c = color.rgb;
    c = (c - 0.5) * 1.5 + 0.5; // Boost contrast
    return float4(c, color.a);
}
