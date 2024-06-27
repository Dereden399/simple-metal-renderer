//
//  VertexDescriptor.swift
//  SimpleMetalRenderer
//
//  Created by Denis Kuznetsov on 27.6.2024.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index
        )
        offset += MemoryLayout<float3>.stride

        vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }
}

extension Attributes {
    var index: Int {
        return Int(self.rawValue)
    }
}

extension BufferIndices {
    var index: Int {
        return Int(self.rawValue)
    }
}
