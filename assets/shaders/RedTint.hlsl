// Red Tint / Danger
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
    float gray = dot(c.rgb, float3(0.3, 0.59, 0.11));
    return float4(gray * 1.5, 0.0, 0.0, 1.0);
}
