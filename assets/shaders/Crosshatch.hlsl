// Crosshatch Shader
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
    float lum = dot(c.rgb, float3(0.3, 0.59, 0.11));
    
    float3 col = float3(1,1,1);
    
    if (lum < 0.8) {
        if (fmod(pos.x + pos.y, 10.0) == 0.0) col = float3(0,0,0);
    }
    if (lum < 0.6) {
        if (fmod(pos.x - pos.y, 10.0) == 0.0) col = float3(0,0,0);
    }
    if (lum < 0.4) {
        if (fmod(pos.x + pos.y - 5.0, 10.0) == 0.0) col = float3(0,0,0);
    }
    
    return float4(col, 1.0);
}
