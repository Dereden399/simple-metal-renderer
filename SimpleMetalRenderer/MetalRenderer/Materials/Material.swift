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
        self.materialParams = MyMaterial(shininess: 64, blendColor: blendColor, emissionStrenght: 1, tiling: [1, 1], useNormalMap: 0, useEmissionMap: 0)
    }
    
    init(textures: Textures) {
        self.textures = textures
        self.materialParams = MyMaterial(shininess: 64, blendColor: [1, 1, 1, 1], emissionStrenght: 1, tiling: [1, 1], useNormalMap: 0, useEmissionMap: 0)
    }
    
    init(mdlMaterial: MDLMaterial, name: String) {
        
        self.textures = Textures(
            diffuseMap: mdlMaterial.texture(type: .baseColor, name: name) ?? ResourcesManager.shared.defaultDiffuseTexture,
            specularMap: mdlMaterial.texture(type: .roughness, name: name) ?? ResourcesManager.shared.defaultSpecularTexture,
            normalMap: mdlMaterial.texture(type: .objectSpaceNormal, name: name),
            emissionMap: mdlMaterial.texture(type: .emission, name: name)
        )
        self.materialParams = MyMaterial(mdlMaterial: mdlMaterial)
    }
}

extension MDLMaterial {
    func texture(type semantic: MDLMaterialSemantic, name: String) -> MTLTexture? {
        if let property = property(with: semantic),
           property.type == .texture,
           let mdlTexture = property.textureSamplerValue?.texture
        {
            return ResourcesManager.shared.loadTexture(texture: mdlTexture, name: name + (property.stringValue ?? UUID().uuidString))
        }
        return nil
    }
}

extension MyMaterial {
    init() {
        self = MyMaterial(shininess: 64, blendColor: [1, 1, 1, 1], emissionStrenght: 1, tiling: [1, 1], useNormalMap: 0, useEmissionMap: 0)
    }
    
    init(mdlMaterial: MDLMaterial) {
        self.init()
        if let baseColor = mdlMaterial.property(with: .baseColor),
           baseColor.type == .float3
        {
            self.blendColor = [baseColor.float3Value.x, baseColor.float3Value.y, baseColor.float3Value.z, 1]
        } else if let baseColor = mdlMaterial.property(with: .baseColor),
                  baseColor.type == .float4
        {
            self.blendColor = [baseColor.float4Value.x, baseColor.float4Value.y, baseColor.float4Value.z, baseColor.float4Value.w]
        }
        
        if let specular = mdlMaterial.property(with: .roughness),
           specular.type == .float {
            self.shininess = (2/pow(specular.floatValue+0.01, 4) - 2)
        }
        
        if let normals = mdlMaterial.property(with: .objectSpaceNormal),
           normals.type == .texture {
            self.useNormalMap = 1
        }
        
        if let emission = mdlMaterial.property(with: .emission),
           emission.type == .texture {
            self.useEmissionMap = 1
        }
    }
}
