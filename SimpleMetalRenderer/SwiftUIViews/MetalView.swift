//
//  MetalView.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit
import SwiftUI

struct MetalView: View {
    @State private var mtkView = MTKView()
    @State private var program: MetalProgram?
    var body: some View {
        MetalViewRepresentable(program: program, metalView: $mtkView)
            .onAppear {
                program = MetalProgram(metalView: mtkView)
            }
            .border(.black)
            .padding()
        Text("Hello world")
    }
}

#if os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let program: MetalProgram?
    @Binding var metalView: MTKView

    #if os(macOS)
        func makeNSView(context: Context) -> some NSView {
            metalView
        }

        func updateNSView(_ uiView: NSViewType, context: Context) {
            updateMetalView()
        }

    #elseif os(iOS)
        func makeUIView(context: Context) -> MTKView {
            metalView
        }

        func updateUIView(_ uiView: MTKView, context: Context) {
            updateMetalView()
        }
    #endif

    func updateMetalView() {}
}

#Preview {
    MetalView()
}
