//
//  Transformable.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 28.6.2024.
//
import Foundation

struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
}

extension Transform {
    var modelMatrix: matrix_float4x4 {
        let translation = float4x4(translation: position)
        let rotation = float4x4(rotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians])
        let scale = float4x4(scaling: scale)
        return translation * rotation * scale
    }
}

protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var position: float3 {
        get { transform.position }
        set { transform.position = newValue }
    }

    var rotation: float3 {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }

    var scale: float3 {
        get { transform.scale }
        set { transform.scale = newValue }
    }
}
