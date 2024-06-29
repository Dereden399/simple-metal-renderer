//
//  Fragment.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"
#import "Shaders.h"

fragment float4 fragment_main(
                              VertexOut input [[stage_in]],
                              constant MyMaterial &_material [[buffer(MaterialBuffer)]],
                              texture2d<float> baseColorTexture [[texture(DiffuseMap)]],
                              texture2d<float> normalTexture [[texture(NormalMap)]],
                              texture2d<float> specularTexture [[texture(SpecularMap)]])
{
    constexpr sampler textureSampler(
                                     filter::linear,
                                     mip_filter::linear,
                                     max_anisotropy(8),
                                     address::repeat);
    float3 color = baseColorTexture.sample(textureSampler, input.uv).rgb;
    return float4(color, 1);
}
