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
    float3 worldNormal;
    float2 uv;
    float3 worldPosition;
    float3 worldTangent;
    float3 worldBitangent;
    float4 shadowPosition;
};


#endif /* Shaders_h */
