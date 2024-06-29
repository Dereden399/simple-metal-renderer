//
//  Lighting.h
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float3 processPhong(constant Light* lights, constant Params& params, constant MyMaterial& material, float3 normal, float3 worldPos, float3 diffuseColor, float3 specularIntensity);

#endif /* Lighting_h */
