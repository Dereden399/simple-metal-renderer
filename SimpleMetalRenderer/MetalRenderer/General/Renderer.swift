//
//  Renderer.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var pipelineState: MTLRenderPipelineState!
    
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("GPU is not available on this device")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.0,
            alpha: 1.0)
    }
}

extension Renderer {
    func draw(in view: MTKView, scene: ProgramScene) {
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(
                descriptor: descriptor)
        else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        for model in scene.models {
            var uniforms = Uniforms()
            uniforms.viewMatrix = scene.selectedCamera?.viewMatrix ?? matrix_float4x4.identity
            uniforms.projectionMatrix = scene.selectedCamera?.projectionMatrix ?? matrix_float4x4.identity
            uniforms.modelMatrix = model.transform.modelMatrix
            
            renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
            
            renderEncoder.setVertexBuffer(model.mesh.vertexBuffers[0].buffer, offset: 0, index: VertexBuffer.index)
            
            for (index, submesh) in model.mesh.submeshes.enumerated() {
                guard var material = model.materials[index] else {
                    fatalError("Something went wrong")
                }
                renderEncoder.setFragmentBytes(&material.materialParams, length: MemoryLayout<MyMaterial>.stride, index: MaterialBuffer.index)
                renderEncoder.setFragmentTexture(material.textures.diffuseMap, index: DiffuseMap.index)
                renderEncoder.setFragmentTexture(material.textures.specularMap, index: SpecularMap.index)
                
                renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            }
            
        }
        
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
          fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
