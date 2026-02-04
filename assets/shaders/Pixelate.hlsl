// Pixelate Shader
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
    float pixels = 128.0; // Number of pixels across
    float dx = 1.0 / pixels;
    float dy = 1.0 / (pixels * (Resolution.y / Resolution.x));
    
    float2 coord = float2(dx * floor(tex.x / dx), dy * floor(tex.y / dy));
    
    return shaderTexture.Sample(samplerState, coord);
}
