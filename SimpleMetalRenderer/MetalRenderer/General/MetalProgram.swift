//
//  MetalProgram.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit

class MetalProgram: NSObject {
    var renderer: Renderer
    var scene: ProgramScene?

    var deltaTime: Double = 0
    var lastTime: Double = CFAbsoluteTimeGetCurrent()

    init(metalView: MTKView) {
        renderer = Renderer(metalView: metalView)
        scene = ProgramScene()
        scene?.initWithBasicObjects()

        super.init()
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
}

extension MetalProgram: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Settings.shared.windowSize = size
        renderer.mainRenderPass.resize(view: view, size: size)
        renderer.shadowsRenderPass.resize(view: view, size: size)
    }

    func draw(in view: MTKView) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = (currentTime - lastTime)
        lastTime = currentTime
        
        if let scene_ = scene {
            for callback in scene_.callbacks {
                callback(currentTime, deltaTime)
            }
            scene_.selectedCamera?.processInput(deltaTime: deltaTime)
            renderer.draw(in: view, scene: scene_)
        }
    }
}
