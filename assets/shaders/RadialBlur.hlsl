// Radial Blur Shader
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
    float2 dir = 0.5 - tex;
    float dist = sqrt(dir.x * dir.x + dir.y * dir.y);
    dir /= dist;
    
    float4 color = float4(0,0,0,0);
    float samples = 10.0;
    
    for (float i = 0.0; i < 10.0; i++) {
        color += shaderTexture.Sample(samplerState, tex + dir * (i * 0.01 * dist));
    }
    
    return color / 10.0;
}
