// Matrix Rain Shader
// Simple green tint and digital noise effect

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
    float4 pixel = shaderTexture.Sample(samplerState, tex);
    if (pixel.a <= 0.0) return pixel;

    // Digital rain strips
    float2 uv = tex;
    uv.y += Time * 0.1;
    float noise = rand(floor(uv * float2(50.0, 10.0)));
    
    // Apply green tint if noise is high
    if (noise > 0.95) {
        pixel.rgb = lerp(pixel.rgb, float3(0.0, 1.0, 0.2), 0.3); // Flash green
    } else {
        pixel.rgb = lerp(pixel.rgb, float3(0.0, 1.0, 0.0) * pixel.g, 0.1); // Subtle green tint
    }
    
    return pixel;
}
