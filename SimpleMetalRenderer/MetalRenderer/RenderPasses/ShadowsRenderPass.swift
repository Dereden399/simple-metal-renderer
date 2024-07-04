//
//  ShadowsRenderPass.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 4.7.2024.
//

import MetalKit

struct ShadowsRenderPass: RenderPass {
    let label = "ShadowsRenderPass"
    var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
    var depthStencilState: MTLDepthStencilState? = Self.buildDepthStencilState()
    var pipelineState: MTLRenderPipelineState
    var shadowTexture: MTLTexture?

    init() {
        pipelineState =
            PipelineStates.createShadowsPSO()
        shadowTexture = Self.makeTexture(size: CGSize(width: 1024, height: 1024), pixelFormat: .depth32Float, label: "Shadow Depth Texture")
    }

    mutating func resize(view: MTKView, size: CGSize) {}

    func draw(commandBuffer: any MTLCommandBuffer, scene: ProgramScene, uniforms: Uniforms) {
        guard let descriptor = descriptor else { return }
        descriptor.depthAttachment.texture = shadowTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store
        guard let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        renderEncoder.label = "Shadow Encoder"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms)
        }
        renderEncoder.endEncoding()
    }
}
