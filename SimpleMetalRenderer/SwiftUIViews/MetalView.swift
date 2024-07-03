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
    @State private var previousTranslation = CGSize.zero
    var body: some View {
        MetalViewRepresentable(program: program, metalView: $mtkView)
            .onAppear {
                program = MetalProgram(metalView: mtkView)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    InputController.shared.touchLocation = value.location
                    InputController.shared.touchDelta = CGSize(
                        width: value.translation.width - previousTranslation.width,
                        height: value.translation.height - previousTranslation.height)
                    previousTranslation = value.translation
                    // if the user drags, cancel the tap touch
                    if abs(value.translation.width) > 1 ||
                        abs(value.translation.height) > 1
                    {
                        InputController.shared.touchLocation = nil
                    }
                }
                .onEnded { _ in
                    previousTranslation = .zero
                })
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
