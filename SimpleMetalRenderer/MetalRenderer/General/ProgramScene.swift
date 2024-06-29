//
//  ProgramScene.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import MetalKit

struct ProgramScene {
    var selectedCamera: Camera?
    var models: [Model]
    
    init(selectedCamera: Camera? = nil, models: [Model] = []) {
        self.selectedCamera = selectedCamera
        self.models = models
    }
}

extension ProgramScene {
    mutating func initWithBasicObjects() {
        self.selectedCamera = PerspectiveCamera()
        self.selectedCamera!.position = [0, 2, -4]
        self.selectedCamera!.rotation = [30, 0, 0]
        
        guard
            var cube = ResourcesManager.shared.loadModel(primitive: .cube, name: "CubeMesh"),
            var sphere = ResourcesManager.shared.loadModel(primitive: .sphere, name: "SphereMesh")
        else {
            fatalError("Error initializing the scene with basic objects")
        }
        self.models = [cube, sphere]
        
        cube.position = [-1, 0, 0]
        cube.setMaterial(ResourcesManager.shared.loadMaterial(name: "CubeMaterial"))
        
        sphere.position = [1, 0, 0]
        sphere.setMaterial(ResourcesManager.shared.loadMaterial(name: "SphereMaterial"))
    }
}
