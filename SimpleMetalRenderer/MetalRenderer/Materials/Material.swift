//
//  Material.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 28.6.2024.
//

import MetalKit

class Material {
    struct Textures {
        var diffuseMap: MTLTexture
        var specularMap: MTLTexture
        var normalMap: MTLTexture?
        var emissionMap: MTLTexture?
    }
    var textures: Textures
    var materialParams: MyMaterial
    
    init(textures: Textures, materialParams: MyMaterial) {
        self.textures = textures
        self.materialParams = materialParams
    }
    
    init(blendColor: float4) {
        self.textures = Textures(diffuseMap: ResourcesManager.shared.defaultDiffuseTexture, specularMap: ResourcesManager.shared.defaultSpecularTexture)
        self.materialParams = MyMaterial(shininess: 64, blendColor: blendColor, emissionStrenght: 1)
    }
    
    init(textures: Textures) {
        self.textures = textures
        self.materialParams = MyMaterial(shininess: 64, blendColor: [1, 1, 1, 1], emissionStrenght: 1)
    }
}
