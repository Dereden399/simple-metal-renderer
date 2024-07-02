//
//  Rendering.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 29.6.2024.
//

import MetalKit

extension Model {
    func render(encoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        var _uniforms = uniforms
        _uniforms.modelMatrix = self.transform.modelMatrix
        _uniforms.normalMatrix = (_uniforms.modelMatrix.inverse.transpose).upperLeft
        
        encoder.setVertexBytes(&_uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        
        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(
                    vertexBuffer.buffer,
                    offset: 0,
                    index: index)
            }
            for materialSubmesh in mesh.submeshes {
                let submesh = materialSubmesh.submesh
                var material: Material
                if let submeshMaterial = materialSubmesh.material {
                    material = submeshMaterial
                } else {
                    material = ResourcesManager.shared.defaultMaterial
                }
                
                encoder.setVertexBytes(&material.materialParams, length: MemoryLayout<MyMaterial>.stride, index: MaterialBuffer.index)
                
                encoder.setFragmentBytes(&material.materialParams, length: MemoryLayout<MyMaterial>.stride, index: MaterialBuffer.index)
                encoder.setFragmentTexture(material.textures.diffuseMap, index: DiffuseMap.index)
                encoder.setFragmentTexture(material.textures.specularMap, index: SpecularMap.index)
                if let normalMap = material.textures.normalMap {
                    encoder.setFragmentTexture(normalMap, index: NormalMap.index)
                }
                if let emissionMap = material.textures.emissionMap {
                    encoder.setFragmentTexture(emissionMap, index: EmissionMap.index)
                }
                
                encoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
    }
}
