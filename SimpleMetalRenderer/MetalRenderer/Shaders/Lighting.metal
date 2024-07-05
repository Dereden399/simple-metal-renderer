//
//  Lighting.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"

constant int SHADOW_SAMPLE_COUNT = 16;
constant float SHADOW_PENUMBRA_SIZE = 2.0;
constant float2 poissonDisk[16] = {
    float2( -0.94201624, -0.39906216 ),
    float2( 0.94558609, -0.76890725 ),
    float2( -0.094184101, -0.92938870 ),
    float2( 0.34495938, 0.29387760 ),
    float2( -0.91588581, 0.45771432 ),
    float2( -0.81544232, -0.87912464 ),
    float2( -0.38277543, 0.27676845 ),
    float2( 0.97484398, 0.75648379 ),
    float2( 0.44323325, -0.97511554 ),
    float2( 0.53742981, -0.47373420 ),
    float2( -0.26496911, -0.41893023 ),
    float2( 0.79197514, 0.19090188 ),
    float2( -0.24188840, 0.99706507 ),
    float2( -0.81409955, 0.91437590 ),
    float2( 0.19984126, 0.78641367 ),
    float2( 0.14383161, -0.14100790 )
};

// Random number generator
float random(float3 seed, int i) {
    float dotProduct = dot(float4(seed, i), float4(12.9898, 78.233, 45.164, 94.673));
    return fract(sin(dotProduct) * 43758.5453);
}

float3 processPhong(constant Light* lights, constant Params& params, constant MyMaterial& material, float3 normal, float3 worldPos, float3 diffuseColor, float3 specularIntensity, depth2d<float> shadowTexture, float4 shadowPosition_)
{
    float3 diffuse = 0;
    float3 specular = 0;
    float3 ambient = 0;
    
    for (unsigned int i = 0; i < params.lightCount; i++) {
        Light light = lights[i];
        switch (light.type) {
            case Sun: {
                float3 lightDirection = normalize(light.position);
                float diffuseIntensity =
                saturate(dot(lightDirection, normal));
                diffuse += light.color * diffuseColor * diffuseIntensity;
                if (diffuseIntensity > 0) {
                    float3 dirToViewer = normalize(params.cameraPos-worldPos);
                    float3 halfwayDir = normalize(dirToViewer + lightDirection);
                    float spec = pow(saturate(dot(normal, halfwayDir)),material.shininess);
                    specular += light.color * spec * specularIntensity;
                }
                ambient += light.ambientIntensity*light.color*diffuseColor;
                break;
            }
            case Spot: {
                float d = distance(light.position, worldPos);
                float3 lightDirection = normalize(light.position - worldPos);
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, -coneDirection);
                if (spotResult > cos(light.coneAngle)) {
                    float attenuation = 1.0 / (light.attenuation.x +
                                               light.attenuation.y * d + light.attenuation.z * d * d);
                    attenuation *= pow(spotResult, light.coneAttenuation);
                    float diffuseIntensity = saturate(dot(lightDirection, normal));
                    diffuse += light.color*diffuseColor*diffuseIntensity*attenuation;
                    if (diffuseIntensity > 0) {
                        float3 dirToViewer = normalize(params.cameraPos-worldPos);
                        float3 halfwayDir = normalize(dirToViewer + lightDirection);
                        float spec = pow(saturate(dot(normal, halfwayDir)),material.shininess);
                        specular += light.color * spec * specularIntensity*attenuation;
                    }
                    ambient += light.ambientIntensity*light.color*attenuation*diffuseColor;
                }
            }
                break;
            case Point: {
                float d = distance(light.position, worldPos);
                float3 lightDirection = normalize(light.position - worldPos);
                float attenuation = 1.0 / (light.attenuation.x +
                                           light.attenuation.y * d + light.attenuation.z * d * d);
                
                float diffuseIntensity = saturate(dot(lightDirection, normal));
                diffuse += light.color*diffuseColor*diffuseIntensity*attenuation;
                if (diffuseIntensity > 0) {
                    float3 dirToViewer = normalize(params.cameraPos-worldPos);
                    float3 halfwayDir = normalize(dirToViewer + lightDirection);
                    float spec = pow(saturate(dot(normal, halfwayDir)),material.shininess);
                    specular += light.color * spec * specularIntensity*attenuation;
                }
                ambient += light.ambientIntensity*light.color*attenuation*diffuseColor;
                break;
            }
        }
    }
    
    float shadow = 0;
    
    // shadow calculation
    float3 shadowPosition = shadowPosition_.xyz / shadowPosition_.w;
    float2 xy = shadowPosition.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    xy = saturate(xy);
    constexpr sampler s(
      coord::normalized, filter::linear,
      address::clamp_to_edge,
      compare_func:: less);
    
    float2 texelSize = 1/float2(shadowTexture.get_width(), shadowTexture.get_height());
    
    for (int i = 0; i < SHADOW_SAMPLE_COUNT; i++) {
        float2 coord = float2(xy + normalize(poissonDisk[i])*random(worldPos, i)*SHADOW_PENUMBRA_SIZE*texelSize);
        float shadow_sample = shadowTexture.sample(s, coord);
        shadow += shadowPosition.z > shadow_sample + 0.005 ? 1.0 : 0.0;
    }
    
    shadow /= SHADOW_SAMPLE_COUNT;
    
    if (shadowPosition.z > 1.0 || shadowPosition.z < 0) {
        shadow = 0;
    }
    
    return (diffuse + specular)*(1-shadow) + ambient;
}
