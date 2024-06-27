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

fragment float4 fragment_main(VertexOut input [[stage_in]]) {
    return float4(1,0,0,1);
}
