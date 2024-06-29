//
//  Camera.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import CoreGraphics

protocol Camera: Transformable {
    var projectionMatrix: float4x4 {get}
    var viewMatrix: float4x4 {get}
}

struct PerspectiveCamera: Camera {
    var transform: Transform = Transform()
    var fov: Float = 45
    var near: Float = 0.1
    var far: Float = 100
    
    var projectionMatrix: float4x4 {
        matrix_float4x4(projectionFov: fov.toRadians, near: near, far: far, aspect: Float(Settings.shared.windowSize.width / Settings.shared.windowSize.height))
    }
    
    var viewMatrix: float4x4 {
        (matrix_float4x4(translation: position)*matrix_float4x4(rotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians])).inverse
    }
    
}
