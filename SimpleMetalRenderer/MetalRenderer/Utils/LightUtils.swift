//
//  LightUtils.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import Foundation

extension Light {
    static func getDefaultLight() -> Light {
        let light = Light(type: Sun, position: [0, 0, 0], radius: 1, color: [1, 1, 1], coneAngle: 0.5, attenuation: [1, 0, 0], coneAttenuation: 1, coneDirection: [0, 0, 1], ambientIntensity: 0.1)
        return light
    }
}
