//
//  Shaders.h
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

#ifndef Shaders_h
#define Shaders_h

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(Uv)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};


#endif /* Shaders_h */
