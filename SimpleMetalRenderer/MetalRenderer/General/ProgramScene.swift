//
//  ProgramScene.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import MetalKit

class ProgramScene {
    var selectedCamera: Camera?
    var models: [Model]
    var lights: [Light]
    
    typealias Callback = (Double, Double) -> Void
    
    var callbacks: [Callback] = []
    
    init(selectedCamera: Camera? = nil, models: [Model] = [], lights: [Light] = []) {
        self.selectedCamera = selectedCamera
        self.models = models
        self.lights = lights
    }
}

extension ProgramScene {
    func initWithBasicObjects() {
        self.selectedCamera = FloatingCamera()
        self.selectedCamera!.position = [0, 0, -4]
        self.selectedCamera!.rotation = [0, 0, 0]
        
        guard
            var cube = ResourcesManager.shared.loadModel(primitive: .cube, meshName: "CubeMesh"),
            var sphere = ResourcesManager.shared.loadModel(primitive: .sphere, meshName: "SphereMesh")
        else {
            fatalError("Error initializing the scene with basic objects")
        }
        self.models = [cube, sphere]
        
        cube.position = [0, -1, 0]
        cube.scale = [10, 10, 0.1]
        cube.rotation = [90, 0, 0]
        let cubeMaterial = ResourcesManager.shared.loadMaterial(name: "CubeMaterial")
        cubeMaterial.materialParams.blendColor = [1, 1, 1, 1]
        cubeMaterial.materialParams.tiling = [10, 10]
        cube.setMaterial(cubeMaterial)
        cubeMaterial.textures.diffuseMap = ResourcesManager.shared.loadTexture(name: "Brickwall")!
        cubeMaterial.textures.normalMap = ResourcesManager.shared.loadTexture(name: "Brickwall_normal")!
        cubeMaterial.materialParams.useNormalMap = 1;
        
//        self.callbacks.append { currentTime, _ in
//            cube.rotation.x = Float(sin(currentTime) * 90)
//        }
        
        sphere.position = [1, 0, 0]
        let sphereMaterial = ResourcesManager.shared.loadMaterial(name: "SphereMaterial")
        sphereMaterial.materialParams.blendColor = [0.05, 1, 0.05, 1]
        sphere.setMaterial(sphereMaterial)
        
        if var model = ResourcesManager.shared.loadModel(modelName: "train.usdz") {
            model.position = [-3, -1, 0]
            model.rotation = [0, 90, 0]
            self.models.append(model)
        }
        
        
        
        
        
        var sun = Light.getDefaultLight()
        sun.type = Sun
        sun.ambientIntensity = 0.2
        sun.position = [2, 2, -2]
        sun.color = [1, 1, 1]
        
        var point = Light.getDefaultLight()
        point.type = Point
        point.ambientIntensity = 0.05
        point.color = [1, 0, 1]
        point.attenuation = [1, 0.4, 0.4]
        point.position = [-1, -0.5, 0]
        
        
        self.lights = [sun, point]
    }
}
