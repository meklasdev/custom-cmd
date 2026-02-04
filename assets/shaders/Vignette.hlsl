// Vignette Shader
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
    float2 uv = tex * (1.0 - tex.yx);
    float vig = uv.x * uv.y * 15.0; 
    vig = pow(vig, 0.25);
    return float4(color.rgb * vig, color.a);
}
