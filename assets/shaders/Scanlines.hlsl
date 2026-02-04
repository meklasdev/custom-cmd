// Simple Scanlines Shader
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
    float scanline = sin(tex.y * Resolution.y * 1.5) * 0.15;
    float3 final = color.rgb - scanline;
    return float4(final, color.a);
}
