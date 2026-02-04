// Sobel Edge Detection
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
    float w = 1.0 / Resolution.x;
    float h = 1.0 / Resolution.y;
    
    float4 n[9];
    n[0] = shaderTexture.Sample(samplerState, tex + float2(-w, -h));
    n[1] = shaderTexture.Sample(samplerState, tex + float2(0, -h));
    n[2] = shaderTexture.Sample(samplerState, tex + float2(w, -h));
    n[3] = shaderTexture.Sample(samplerState, tex + float2(-w, 0));
    n[4] = shaderTexture.Sample(samplerState, tex);
    n[5] = shaderTexture.Sample(samplerState, tex + float2(w, 0));
    n[6] = shaderTexture.Sample(samplerState, tex + float2(-w, h));
    n[7] = shaderTexture.Sample(samplerState, tex + float2(0, h));
    n[8] = shaderTexture.Sample(samplerState, tex + float2(w, h));

    float4 sobel_h = n[2] + (2.0*n[5]) + n[8] - (n[0] + (2.0*n[3]) + n[6]);
    float4 sobel_v = n[0] + (2.0*n[1]) + n[2] - (n[6] + (2.0*n[7]) + n[8]);
    float4 sobel = sqrt((sobel_h * sobel_h) + (sobel_v * sobel_v));

    return float4(sobel.rgb, 1.0);
}
