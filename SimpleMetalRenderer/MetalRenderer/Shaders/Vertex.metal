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
    VertexOut out = {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * input.position,
        .uv = input.uv + float2(0.5, 0.5)
    };
    return out;
}
