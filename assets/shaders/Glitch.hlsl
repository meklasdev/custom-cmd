// Glitch Shader
// Chromatic aberration and pixel shifting

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
    // Time-based glitch factor
    float glitchIntensity = 0.0;
    if (fmod(Time, 3.0) > 2.8) {
        glitchIntensity = 0.02; // Occasional glitch
    }
    
    // Chromatic Aberration
    floatr = shaderTexture.Sample(samplerState, tex + float2(glitchIntensity, 0)).r;
    float g = shaderTexture.Sample(samplerState, tex).g;
    float b = shaderTexture.Sample(samplerState, tex - float2(glitchIntensity, 0)).b;
    
    return float4(r, g, b, 1.0);
}
