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
    
    var mainRenderPass: MainRenderPass
    
    var uniforms: Uniforms = Uniforms()
    
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
        
        mainRenderPass = .init(view: metalView)
        
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.1,
            green: 0.1,
            blue: 0.1,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
    }
}

extension Renderer {
    func draw(in view: MTKView, scene: ProgramScene) {
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
        else {
            return
        }
        mainRenderPass.descriptor = descriptor
        mainRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms)
        

        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
