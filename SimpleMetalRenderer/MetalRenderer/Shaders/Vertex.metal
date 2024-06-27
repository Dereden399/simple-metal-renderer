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

vertex VertexOut vertex_main(VertexIn input [[stage_in]]) {
    VertexOut out = {
        .position = input.position
    };
    return out;
}
