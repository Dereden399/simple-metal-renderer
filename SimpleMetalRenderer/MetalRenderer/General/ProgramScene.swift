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
    var lights: [Light]
    
    init(selectedCamera: Camera? = nil, models: [Model] = [], lights: [Light] = []) {
        self.selectedCamera = selectedCamera
        self.models = models
        self.lights = lights
    }
}

extension ProgramScene {
    mutating func initWithBasicObjects() {
        self.selectedCamera = PerspectiveCamera()
        self.selectedCamera!.position = [0, 2, -4]
        self.selectedCamera!.rotation = [30, 0, 0]
        
        guard
            var cube = ResourcesManager.shared.loadModel(primitive: .cube, meshName: "CubeMesh"),
            var sphere = ResourcesManager.shared.loadModel(primitive: .sphere, meshName: "SphereMesh")
        else {
            fatalError("Error initializing the scene with basic objects")
        }
        self.models = [cube, sphere]
        
        cube.position = [-1, 0, 0]
        let cubeMaterial = ResourcesManager.shared.loadMaterial(name: "CubeMaterial")
        cubeMaterial.materialParams.blendColor = [1, 1, 1, 1]
        cube.setMaterial(cubeMaterial)
        cubeMaterial.textures.diffuseMap = ResourcesManager.shared.loadTexture(name: "Container")!
        
        sphere.position = [1, 0, 0]
        let sphereMaterial = ResourcesManager.shared.loadMaterial(name: "SphereMaterial")
        sphereMaterial.materialParams.blendColor = [0, 1, 0, 1]
        sphere.setMaterial(sphereMaterial)
        
        var sun = Light.getDefaultLight()
        sun.type = Sun
        sun.ambientIntensity = 0.1
        sun.position = [2, 1, -2]
        sun.color = [1, 1, 1]
        
        lights = [sun]
    }
}
