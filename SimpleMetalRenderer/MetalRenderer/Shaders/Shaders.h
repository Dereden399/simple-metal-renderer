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
};

struct VertexOut {
    float4 position [[position]];
};


#endif /* Shaders_h */
