// Hue Shift Shader
Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

float3 hueShift(float3 color, float shift){
    float3 P = float3(0.55735, 0.55735, 0.55735) * dot(float3(0.55735, 0.55735, 0.55735), color);
    float3 U = color - P;
    float3 V = cross(float3(0.55735, 0.55735, 0.55735), U);
    float3 final = U * cos(shift * 6.28318) + V * sin(shift * 6.28318) + P;
    return final;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    color.rgb = hueShift(color.rgb, Time * 0.1); // Slow cycle
    return color;
}
