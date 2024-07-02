//
//  Settings.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import CoreGraphics

// Singleton
class Settings {
    static var shared = Settings();
    
    var windowSize: CGSize = CGSize(width: 0, height: 0)
    var rotatingSpeed: Float = 50
    var movingSpeed: Float = 4
    
    private init() {}
}
