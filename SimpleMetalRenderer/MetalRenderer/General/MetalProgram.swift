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
        Settings.shared.windowSize = size;
    }
    
    func draw(in view: MTKView) {
        if let scene_ = scene {
            renderer.draw(in: view, scene: scene_)
        }
    }
}
