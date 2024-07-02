//
//  Utils.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import CoreGraphics
import simd

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

extension Float {
    var toDegrees: Float {
        (self / Float.pi) * 180
    }
    
    var toRadians: Float {
        (self / 180) * Float.pi
    }
}

// MARK: - float4

extension float4x4 {
    // MARK: - Translate
    
    init(translation: float3) {
        let matrix = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }
    
    // MARK: - Scale
    
    init(scaling: float3) {
        let matrix = float4x4(
            [scaling.x, 0, 0, 0],
            [0, scaling.y, 0, 0],
            [0, 0, scaling.z, 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }
    
    // MARK: - Rotate
    
    init(rotationX angle: Float) {
        let matrix = float4x4(
            [1, 0, 0, 0],
            [0, cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }
    
    init(rotationY angle: Float) {
        let matrix = float4x4(
            [cos(angle), 0, -sin(angle), 0],
            [0, 1, 0, 0],
            [sin(angle), 0, cos(angle), 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }
    
    init(rotationZ angle: Float) {
        let matrix = float4x4(
            [cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
        self = matrix
    }
    
    init(rotation angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
    
    init(rotationYXZ angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationY * rotationX * rotationZ
    }
    
    init(quatRotation angle: float3) {
        let pitch = angle.y
        let yaw = angle.z
        let roll = angle.x
                
        let cy = cos(yaw * 0.5)
        let sy = sin(yaw * 0.5)
        let cp = cos(pitch * 0.5)
        let sp = sin(pitch * 0.5)
        let cr = cos(roll * 0.5)
        let sr = sin(roll * 0.5)
                
        let qw = cr * cp * cy + sr * sp * sy
        let qx = sr * cp * cy - cr * sp * sy
        let qy = cr * sp * cy + sr * cp * sy
        let qz = cr * cp * sy - sr * sp * cy
                
        let quaternion = simd_quatf(ix: qx, iy: qy, iz: qz, r: qw)
        self = float4x4(quaternion)
    }
    
    // MARK: - Identity
    
    static var identity: float4x4 {
        matrix_identity_float4x4
    }
    
    // MARK: - Upper left 3x3
    
    var upperLeft: float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }
    
    // MARK: - Left handed projection matrix
    
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = float4(x, 0, 0, 0)
        let Y = float4(0, y, 0, 0)
        let Z = lhs ? float4(0, 0, z, 1) : float4(0, 0, z, -1)
        let W = lhs ? float4(0, 0, z * -near, 0) : float4(0, 0, z * near, 0)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    // left-handed LookAt
    init(eye: float3, center: float3, up: float3) {
        let z = normalize(center - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        
        let X = float4(x.x, y.x, z.x, 0)
        let Y = float4(x.y, y.y, z.y, 0)
        let Z = float4(x.z, y.z, z.z, 0)
        let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)
        
        self.init()
        columns = (X, Y, Z, W)
    }
    
    // MARK: - Orthographic matrix
    
    init(orthographic rect: CGRect, near: Float, far: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.origin.y - rect.height)
        let X = float4(2 / (right - left), 0, 0, 0)
        let Y = float4(0, 2 / (top - bottom), 0, 0)
        let Z = float4(0, 0, 1 / (far - near), 0)
        let W = float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1
        )
        self.init()
        columns = (X, Y, Z, W)
    }
}

// MARK: - float4

extension float4 {
    var xyz: float3 {
        get {
            float3(x, y, z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}
