//
//  ResourcesManager.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 28.6.2024.
//

import MetalKit

enum PrimitiveType {
    case cube, plane, sphere
}

// Singleton Object
class ResourcesManager {
    static let shared = ResourcesManager()

    var textures: [String: MTLTexture] = [:]
    var materials: [String: Material] = [:]
    var meshes: [String: MTKMesh] = [:]

    private(set) var defaultDiffuseTexture: MTLTexture!
    private(set) var defaultSpecularTexture: MTLTexture!
    private(set) var defaultMaterial: Material!

    private init() {
        guard
            let defaultDiffuseTexture_ = loadTexture(name: "DefaultDiffuse"),
            let defaultSpecularTexture_ = loadTexture(name: "DefaultSpecular")
        else {
            fatalError("Can not load default textures")
        }
        defaultDiffuseTexture = defaultDiffuseTexture_
        defaultSpecularTexture = defaultSpecularTexture_
        let material = Material(textures: .init(diffuseMap: defaultDiffuseTexture_, specularMap: defaultSpecularTexture_))
        materials["DefaultMaterial"] = material
        defaultMaterial = material
    }

    func loadTexture(name: String) -> MTLTexture? {
        if let texture = textures[name] {
            return texture
        }
        let textureLoader = MTKTextureLoader(device: Renderer.device)

        do {
            let texture = try textureLoader.newTexture(name: name, scaleFactor: 1, bundle: Bundle.main)
            print("loaded texture: \(name)")
            textures[name] = texture
            return texture
        } catch {
            print("Error loading the texture from assets with name \(name)")
            return nil
        }
    }

    func loadTexture(texture: MDLTexture, name: String) -> MTLTexture? {
        if let texture = textures[name] {
            return texture
        }
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
            [.origin: MTKTextureLoader.Origin.bottomLeft,
             .generateMipmaps: true]
        let texture = try? textureLoader.newTexture(
            texture: texture,
            options: textureLoaderOptions)
        if texture == nil {
            print("Error loading the texture")
        }
        textures[name] = texture
        return texture
    }
    
    func loadMaterial(name: String) -> Material {
        if let material = materials[name] {
            return material
        }
        let material = Material(blendColor: [1, 1, 1, 1])
        materials[name] = material
        print("loaded material: \(name)")
        return material
    }
    
    func loadModel(primitive: PrimitiveType, meshName: String) -> Model? {
        if let mesh = meshes[meshName] {
            let model = Model(meshes: [mesh])
            return model;
        }
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let mdlMesh: MDLMesh = {
            switch primitive {
            case .cube:
                return MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
            case .plane:
                return MDLMesh(planeWithExtent: [1, 1, 1], segments: [2], geometryType: .triangles, allocator: allocator)
            case .sphere:
                return MDLMesh(sphereWithExtent: [1, 1, 1], segments: [20, 20], inwardNormals: false, geometryType: .triangles, allocator: allocator)
            }
        }()
        mdlMesh.vertexDescriptor = .defaultLayout
        if let mtkMesh = try? MTKMesh(mesh: mdlMesh, device: Renderer.device) {
            meshes[meshName] = mtkMesh
            let model = Model(meshes: [mtkMesh])
            print("loaded new mesh: \(meshName)")
            return model;
        } else {
            print("Error converting mdlmesh to mtkmesh")
            return nil
        }
    }
}
