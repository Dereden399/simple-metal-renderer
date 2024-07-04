//
//  Camera.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import CoreGraphics

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    
    mutating func processInput(deltaTime: Double)
}

struct FloatingPerspectiveCamera: Camera {
    var transform: Transform = .init()
    var fov: Float = 45
    var near: Float = 0.1
    var far: Float = 50
    
    var aspect: Double {
        Settings.shared.windowSize.width / Settings.shared.windowSize.height
    }
    
    var forwardVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(0, 0, 1)
    }
    
    var rightVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(1, 0, 0)
    }
    
    var upVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(0, 1, 0)
    }
    
    var projectionMatrix: float4x4 {
        matrix_float4x4(projectionFov: fov.toRadians, near: near, far: far, aspect: Float(aspect))
    }
    
    var viewMatrix: float4x4 {
        (matrix_float4x4(translation: position) * matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians])).inverse
    }
    
    mutating func processInput(deltaTime: Double) {
        var transform = Transform()
        let rotationAmount = Float(deltaTime) * Settings.shared.rotatingSpeed
        let input = InputController.shared
        
        if input.keysPressed.contains(.leftArrow) {
            transform.rotation.y -= Float(rotationAmount)
        }
        else if input.keysPressed.contains(.rightArrow) {
            transform.rotation.y += Float(rotationAmount)
        }
        if input.keysPressed.contains(.upArrow) {
            transform.rotation.x -= Float(rotationAmount)
        }
        else if input.keysPressed.contains(.downArrow) {
            transform.rotation.x += Float(rotationAmount)
        }
        
        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {
            direction += forwardVector
        }
        else if input.keysPressed.contains(.keyS) {
            direction -= forwardVector
        }
        if input.keysPressed.contains(.keyA) {
            direction -= rightVector
        }
        else if input.keysPressed.contains(.keyD) {
            direction += rightVector
        }
        if input.keysPressed.contains(.spacebar) {
            direction += upVector
        }
        else if input.keysPressed.contains(.leftShift) {
            direction -= upVector
        }
        let translationAmount = Float(deltaTime) * Settings.shared.movingSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += direction * translationAmount
        }
        position += transform.position
        rotation.y += transform.rotation.y
        
        let newXrot = rotation.x + transform.rotation.x
        if abs(newXrot) < 90 {
            rotation.x = newXrot
        }
    }
}

struct FloatingOrthographicCamera: Camera {
    var transform = Transform()
    var viewSize: CGFloat = 16
    var near: Float = 0.1
    var far: Float = 100
    var center = float3.zero
    
    var forwardVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(0, 0, 1)
    }
    
    var rightVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(1, 0, 0)
    }
    
    var upVector: float3 {
        matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians]).upperLeft * float3(0, 1, 0)
    }
    
    
    var aspect: Double {
        Settings.shared.windowSize.width / Settings.shared.windowSize.height
    }
    
    var viewMatrix: float4x4 {
        (matrix_float4x4(translation: position) * matrix_float4x4(quatRotation: [rotation.x.toRadians, rotation.y.toRadians, rotation.z.toRadians])).inverse
    }

    var projectionMatrix: float4x4 {
        let rect = CGRect(
            x: -viewSize * aspect * 0.5,
            y: viewSize * 0.5,
            width: viewSize * aspect,
            height: viewSize)
        return float4x4(orthographic: rect, near: near, far: far)
    }
    
    mutating func processInput(deltaTime: Double) {
        var transform = Transform()
        let rotationAmount = Float(deltaTime) * Settings.shared.rotatingSpeed
        let input = InputController.shared
        
        if input.keysPressed.contains(.leftArrow) {
            transform.rotation.y -= Float(rotationAmount)
        }
        else if input.keysPressed.contains(.rightArrow) {
            transform.rotation.y += Float(rotationAmount)
        }
        if input.keysPressed.contains(.upArrow) {
            transform.rotation.x -= Float(rotationAmount)
        }
        else if input.keysPressed.contains(.downArrow) {
            transform.rotation.x += Float(rotationAmount)
        }
        
        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {
            direction += forwardVector
        }
        else if input.keysPressed.contains(.keyS) {
            direction -= forwardVector
        }
        if input.keysPressed.contains(.keyA) {
            direction -= rightVector
        }
        else if input.keysPressed.contains(.keyD) {
            direction += rightVector
        }
        if input.keysPressed.contains(.spacebar) {
            direction += upVector
        }
        else if input.keysPressed.contains(.leftShift) {
            direction -= upVector
        }
        let translationAmount = Float(deltaTime) * Settings.shared.movingSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += direction * translationAmount
        }
        position += transform.position
        rotation.y += transform.rotation.y
        
        let newXrot = rotation.x + transform.rotation.x
        if abs(newXrot) < 90 {
            rotation.x = newXrot
        }
    }
}
