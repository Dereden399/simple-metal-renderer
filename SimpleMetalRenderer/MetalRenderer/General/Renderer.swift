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
    
    var testMesh: MDLMesh
    
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
        
        testMesh = MDLMesh(sphereWithExtent: [1, 1, 1], segments: [100, 100], inwardNormals: false, geometryType: .triangles, allocator: MTKMeshBufferAllocator(device: device))
        testMesh.vertexDescriptor = .defaultLayout
        
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.0,
            alpha: 1.0)
    }
}

extension Renderer {
    func draw(in view: MTKView) {
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
        
        let testMTKMesh = try! MTKMesh(mesh: testMesh, device: Renderer.device)
        renderEncoder.setVertexBuffer(testMTKMesh.vertexBuffers[0].buffer, offset: 0, index: VertexBuffer.index)
        guard let submesh = testMTKMesh.submeshes.first else {
          fatalError()
        }
        
        renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
          fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
