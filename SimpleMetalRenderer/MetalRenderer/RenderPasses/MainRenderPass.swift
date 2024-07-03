//
//  MainRenderPass.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 3.7.2024.
//
import MetalKit

struct MainRenderPass: RenderPass {
    let label = "Main Render Pass"
    var descriptor: MTLRenderPassDescriptor?

    var pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?

    weak var idTexture: MTLTexture?

    init(view: MTKView) {
        pipelineState = PipelineStates.createMainPSO(
            colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
    }

    mutating func resize(view: MTKView, size: CGSize) {}

    func draw(
        commandBuffer: MTLCommandBuffer,
        scene: ProgramScene,
        uniforms: Uniforms)
    {
        guard let descriptor = descriptor,
              let renderEncoder =
              commandBuffer.makeRenderCommandEncoder(
                  descriptor: descriptor)
        else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)

        var lights = scene.lights
        renderEncoder.setFragmentBytes(
            &lights,
            length: MemoryLayout<Light>.stride * lights.count,
            index: LightsBuffer.index)

        var params = Params(lightCount: uint(lights.count), cameraPos: scene.selectedCamera!.position)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        
        var uniforms_ = uniforms
        
        uniforms_.viewMatrix = scene.selectedCamera?.viewMatrix ?? matrix_float4x4.identity
        uniforms_.projectionMatrix = scene.selectedCamera?.projectionMatrix ?? matrix_float4x4.identity

        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms_)
        }
        renderEncoder.endEncoding()
    }
}
