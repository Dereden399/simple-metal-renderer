//
//  Lighting.metal
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"

float3 processPhong(constant Light* lights, constant Params& params, constant MyMaterial& material, float3 normal, float3 worldPos, float3 diffuseColor, float3 specularIntensity)
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
    
    return diffuse + specular + ambient;
}
