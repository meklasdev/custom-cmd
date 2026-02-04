// Night Vision Shader
// Green tint, noise, and vignette

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

float rand(float2 co){
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    
    // Green tint
    float3 vision = float3(0.1, 0.95, 0.2); // NVG phosphor color
    float intensity = dot(color.rgb, float3(0.299, 0.587, 0.114));
    
    // Noise
    float noise = rand(tex * Time) * 0.2;
    
    // Vignette (Binocular shape roughly)
    float2 uv = tex * (1.0 - tex.yx);
    float vignette = uv.x * uv.y * 50.0; // tighter vignette
    vignette = pow(vignette, 0.25);

    float3 finalColor = (intensity + noise) * vision * vignette;
    
    return float4(finalColor, 1.0);
}
