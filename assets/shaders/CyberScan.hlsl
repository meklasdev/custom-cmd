// Cyber Scanlines (Moving)
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
    
    // Moving thick scanline
    float linePos = frac(Time * 0.5);
    float dist = abs(tex.y - linePos);
    
    if (dist < 0.05) {
        c.rgb += float3(0.0, 0.3 * (0.05 - dist) / 0.05, 0.0);
    }
    
    // Grid
    if (frac(tex.x * 20.0) < 0.02 || frac(tex.y * 20.0) < 0.02) {
        c.rgb *= 0.8;
    }
    
    return c;
}
