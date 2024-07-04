//
//  Lighting.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"

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
    float shadow_sample = shadowTexture.sample(s, xy);
    if (shadowPosition.z > shadow_sample + 0.001) {
        shadow = 1;
    }
    if (shadowPosition.z > 1.0 || shadowPosition.z < 0) {
        shadow = 0;
    }
    
    return (diffuse + specular)*(1-shadow) + ambient;
}
