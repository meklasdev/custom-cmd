// Ripple / Water Effect Shader
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
    float2 uv = tex;
    uv.x += sin(uv.y * 30.0 + Time * 2.0) * 0.005;
    uv.y += cos(uv.x * 30.0 + Time * 2.0) * 0.005;
    
    return shaderTexture.Sample(samplerState, uv);
}
