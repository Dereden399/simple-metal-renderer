//
//  Common.h
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
    VertexBuffer = 0,
    UniformsBuffer = 1,
    MaterialBuffer = 2
} BufferIndices;


typedef enum {
    Position = 0,
    Normal = 1,
    Uv = 2,
    Tangent = 3,
    Bitangent = 4
} Attributes;

typedef enum {
    DiffuseMap = 0,
    SpecularMap = 1,
    NormalMap = 2,
    EmissionMap = 3
} TextureIndices;

typedef struct {
    float shininess;
    vector_float3 blendColor;
    float emissionStrenght;
} MyMaterial;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

#endif /* Common_h */
