// Fish Eye Lens Distortion
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
    float2 uv = tex - 0.5;
    float z = sqrt(1.0 - uv.x * uv.x - uv.y * uv.y);
    float a = 1.0 / (z * tan(0.5 * 3.14159)); // FOV
    float2 newUV = uv * a + 0.5;
    
    if (newUV.x < 0.0 || newUV.x > 1.0 || newUV.y < 0.0 || newUV.y > 1.0)
        return float4(0, 0, 0, 1.0);
        
    return shaderTexture.Sample(samplerState, newUV);
}
