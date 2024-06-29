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
    MaterialBuffer = 2,
    ParamsBuffer = 3,
    LightsBuffer = 4
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
    vector_float4 blendColor;
    float emissionStrenght;
} MyMaterial;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    uint lightCount;
    vector_float3 cameraPos;
} Params;

typedef enum {
    Sun = 1,
    Spot = 2,
    Point = 3,
} LightType;

typedef struct {
    LightType type;
    vector_float3 position;
    float radius;
    vector_float3 color;
    float coneAngle;
    vector_float3 attenuation;
    float coneAttenuation;
    vector_float3 coneDirection;
    float ambientIntensity;
} Light;

#endif /* Common_h */
