//
//  Model.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit

class Model: Transformable {
    var transform: Transform
    var meshes: [MeshWithMaterials]
    
    init(meshes: [MTKMesh]) {
        self.meshes = meshes.map {MeshWithMaterials(mesh: $0)};
        self.transform = .init()
    }
    
    func setMaterial(_ material: Material?) {
        for i in 0..<meshes.count {
            for j in 0..<meshes[i].submeshes.count {
                meshes[i].submeshes[j].material = material
            }
        }
    }
    func setMaterial(forMesh i: Int, forSubmesh j: Int, _ material: Material?) {
        meshes[i].submeshes[j].material = material
    }
}

extension Model {
    struct SubmeshWithMaterial {
        let submesh: MTKSubmesh
        var material: Material?
    }
    struct MeshWithMaterials {
        let vertexBuffers: [MTKMeshBuffer]
        var submeshes: [SubmeshWithMaterial]
        
        init(mesh: MTKMesh) {
            self.vertexBuffers = mesh.vertexBuffers
            self.submeshes = mesh.submeshes.map {submesh in
                SubmeshWithMaterial(submesh: submesh, material: nil)
            }
        }
    }
}
