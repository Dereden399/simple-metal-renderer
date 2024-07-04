//
//  Fragment.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"
#import "Shaders.h"

fragment float4 fragment_main(
                              VertexOut input [[stage_in]],
                              constant MyMaterial &material [[buffer(MaterialBuffer)]],
                              constant Light* lights [[buffer(LightsBuffer)]],
                              constant Params &params [[buffer(ParamsBuffer)]],
                              texture2d<float> baseColorTexture [[texture(DiffuseMap)]],
                              texture2d<float> normalTexture [[texture(NormalMap)]],
                              texture2d<float> specularTexture [[texture(SpecularMap)]],
                              texture2d<float> emissionTexture [[texture(EmissionMap)]],
                              depth2d<float> shadowTexture [[texture(15)]])
{
    constexpr sampler textureSampler(
                                     filter::linear,
                                     mip_filter::linear,
                                     address::repeat);
    float4 diffuseColor = baseColorTexture.sample(textureSampler, input.uv) * material.blendColor;
    float3 specularIntensity = specularTexture.sample(textureSampler, input.uv).rgb;
    float3 normal = input.worldNormal;
    if (material.useNormalMap) {
        normal = normalTexture.sample(textureSampler, input.uv).rgb;
        normal = normal*2 - 1;
        normal = float3x3(input.worldTangent, input.worldBitangent, input.worldNormal)*normal;
    }
    normal = normalize(normal);
    
    float3 result = processPhong(lights, params, material, normal, input.worldPosition, diffuseColor.rgb, specularIntensity, shadowTexture, input.shadowPosition);
    
    float3 emission = float3(0, 0, 0);
    if (material.useEmissionMap) {
        emission = emissionTexture.sample(textureSampler, input.uv).rgb;
    }
    result += emission;
    
    return float4(result, diffuseColor.a);
}
