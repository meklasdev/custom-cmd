// CRT Amber Monitor Shader
// Heavy scanlines and monochromatic amber/orange

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
    if(color.a <= 0.0) return color;

    // Intensity
    float intensity = dot(color.rgb, float3(0.299, 0.587, 0.114));
    
    // Scanlines
    float scanline = sin(tex.y * Resolution.y * 3.0) * 0.25;
    intensity -= scanline;

    // Amber Color (FFB000)
    return float4(intensity * 1.0, intensity * 0.7, 0.0, 1.0);
}
