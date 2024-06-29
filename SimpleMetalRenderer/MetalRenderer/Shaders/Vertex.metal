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
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]] )
{
    float4 worldPosition = uniforms.modelMatrix * input.position;
    VertexOut out = {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * input.position,
        .worldNormal = uniforms.normalMatrix*input.normal,
        .worldPosition = worldPosition.xyz / worldPosition.w,
        .worldTangent = uniforms.normalMatrix*input.tangent,
        .worldBitangent = uniforms.normalMatrix*input.bitangent,
        .uv = input.uv
    };
    return out;
}
