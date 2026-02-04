// CRT/Retro Shader for Windows Terminal
// Simulates scanlines and slight chromatic aberration

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

#define SCANLINE_FACTOR 0.5
#define SCALED_SCANLINE_PERIOD 2.0
#define SCALED_GAUSSIAN_SIGMA 2.0

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float3 color = shaderTexture.Sample(samplerState, tex).rgb;
    
    // Scanline effect (Reduced intensity)
    float scanline = sin(tex.y * Resolution.y * SCANLINE_FACTOR) * 0.02; // Reduced from 0.1 to 0.02
    color -= scanline;
    
    // Vignette (Reduced intensity)
    float2 uv = tex * (1.0 - tex.yx);
    float vignette = uv.x * uv.y * 15.0;
    vignette = pow(vignette, 0.1); // Lighter power
    // Mix vignette with original based on intensity to avoid dark corners
    color = lerp(color, color * vignette, 0.3); // Only 30% vignette strength
    
    return float4(color, 1.0);
}
