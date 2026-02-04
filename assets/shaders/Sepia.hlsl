// Sepia Tone Shader
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
    float3 sepia = float3(1.2, 1.0, 0.8);
    float gray = dot(color.rgb, float3(0.299, 0.587, 0.114));
    float3 final = gray * sepia;
    return float4(final, color.a);
}
