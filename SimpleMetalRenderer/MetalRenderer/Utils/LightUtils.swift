//
//  LightUtils.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import CoreGraphics

extension Light {
    static func getDefaultLight() -> Light {
        let light = Light(type: Sun, position: [0, 0, 0], radius: 1, color: [1, 1, 1], coneAngle: 0.5, attenuation: [1, 0, 0], coneAttenuation: 1, coneDirection: [0, 0, 1], ambientIntensity: 0.1)
        return light
    }
}

struct FrustumPoints {
    var viewMatrix = float4x4.identity
    var upperLeft = float3.zero
    var upperRight = float3.zero
    var lowerRight = float3.zero
    var lowerLeft = float3.zero
}

extension FloatingOrthographicCamera {
    static func createShadowCamera(using camera: Camera, lightPosition: float3) -> FloatingOrthographicCamera {
        guard let camera = camera as? FloatingPerspectiveCamera else { return FloatingOrthographicCamera() }
        let nearPoints = calculatePlane(camera: camera, distance: camera.near)
        let farPoints = calculatePlane(camera: camera, distance: camera.far)

        // calculate bounding sphere of camera
        let radius1 = distance(nearPoints.lowerLeft, farPoints.upperRight) * 0.5
        let radius2 = distance(farPoints.lowerLeft, farPoints.upperRight) * 0.5
        var center: float3
        if radius1 > radius2 {
            center = simd_mix(nearPoints.lowerLeft, farPoints.upperRight, [0.5, 0.5, 0.5])
        } else {
            center = simd_mix(farPoints.lowerLeft, farPoints.upperRight, [0.5, 0.5, 0.5])
        }
        let radius = max(radius1, radius2)

        // create shadow camera using bounding sphere
        var shadowCamera = FloatingOrthographicCamera()
        let direction = normalize(lightPosition)
        shadowCamera.position = center + direction * radius
        shadowCamera.far = radius * 2
        shadowCamera.near = 0.01
        shadowCamera.viewSize = CGFloat(shadowCamera.far)
        shadowCamera.center = center
        return shadowCamera
    }

    static func calculatePlane(camera: FloatingPerspectiveCamera, distance: Float) -> FrustumPoints {
        let halfFov = camera.fov * 0.5
        let halfHeight = tan(halfFov) * distance
        let halfWidth = halfHeight * Float(camera.aspect)
        return calculatePlanePoints(
          matrix: camera.viewMatrix,
          halfWidth: halfWidth,
          halfHeight: halfHeight,
          distance: distance,
          position: camera.position)
      }

    private static func calculatePlanePoints(
        matrix: float4x4,
        halfWidth: Float,
        halfHeight: Float,
        distance: Float,
        position: float3) -> FrustumPoints
    {
        let forwardVector: float3 = [matrix.columns.0.z, matrix.columns.1.z, matrix.columns.2.z]
        let rightVector: float3 = [matrix.columns.0.x, matrix.columns.1.x, matrix.columns.2.x]
        let upVector = cross(forwardVector, rightVector)
        let centerPoint = position + forwardVector * distance
        let moveRightBy = rightVector * halfWidth
        let moveDownBy = upVector * halfHeight

        let upperLeft = centerPoint - moveRightBy + moveDownBy
        let upperRight = centerPoint + moveRightBy + moveDownBy
        let lowerRight = centerPoint + moveRightBy - moveDownBy
        let lowerLeft = centerPoint - moveRightBy - moveDownBy
        let points = FrustumPoints(
            viewMatrix: matrix,
            upperLeft: upperLeft,
            upperRight: upperRight,
            lowerRight: lowerRight,
            lowerLeft: lowerLeft)
        return points
    }
}
