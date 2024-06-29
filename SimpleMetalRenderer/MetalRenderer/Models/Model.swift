//
//  Model.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit

class Model: Transformable {
    var transform: Transform
    var mesh: MTKMesh
    var materials: [Int: Material]
    
    init(mesh: MTKMesh) {
        self.mesh = mesh;
        self.transform = .init()
        self.materials = [:]
    }
    
    func setMaterial(forSubmesh idx: Int, _ material: Material) {
        materials[idx] = material
    }
    
    func setMaterial(_ material: Material) {
        for i in 0..<mesh.submeshes.count {
            materials[i] = material
        }
    }
}
