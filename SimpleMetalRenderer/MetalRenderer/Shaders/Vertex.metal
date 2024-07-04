//
//  Vertex.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"
#import "Shaders.h"

vertex VertexOut vertex_main(VertexIn input [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                             constant MyMaterial &material [[buffer(MaterialBuffer)]])
{
    float4 worldPosition = uniforms.modelMatrix * input.position;
    VertexOut out = {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * input.position,
        .worldNormal = uniforms.normalMatrix*input.normal,
        .worldPosition = worldPosition.xyz / worldPosition.w,
        .worldTangent = (uniforms.modelMatrix*float4(input.tangent, 0)).xyz,
        .worldBitangent = (uniforms.modelMatrix*float4(input.bitangent,0)).xyz,
        .uv = {input.uv.x * material.tiling.x, input.uv.y*material.tiling.y},
        .shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * input.position
    };
    return out;
}
