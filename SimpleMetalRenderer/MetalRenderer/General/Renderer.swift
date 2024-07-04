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
    var shadowsRenderPass: ShadowsRenderPass
    
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
        shadowsRenderPass = .init()
        
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
        
        uniforms.viewMatrix = scene.selectedCamera?.viewMatrix ?? matrix_float4x4.identity
        uniforms.projectionMatrix = scene.selectedCamera?.projectionMatrix ?? matrix_float4x4.identity
        
        var shadowCamera = FloatingOrthographicCamera()
        shadowCamera.viewSize = 16
        shadowCamera.far = 16
        let sun = scene.lights[0]
        shadowCamera.position = sun.position
        
        uniforms.shadowProjectionMatrix = shadowCamera.projectionMatrix
        uniforms.shadowViewMatrix = float4x4(
            eye: sun.position,
            center: .zero,
          up: [0, 1, 0])
        
        //uniforms.viewMatrix = uniforms.shadowViewMatrix
        //uniforms.projectionMatrix = uniforms.shadowProjectionMatrix
        
        shadowsRenderPass.draw(
          commandBuffer: commandBuffer,
          scene: scene,
          uniforms: uniforms)
        
        mainRenderPass.shadowTexture = shadowsRenderPass.shadowTexture
        
        mainRenderPass.descriptor = descriptor
        mainRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms)
        

        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
