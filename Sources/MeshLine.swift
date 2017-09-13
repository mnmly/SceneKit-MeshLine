//
//  MeshLine.swift
//  AnimationDemo
//
//  Created by Hiroaki Yamane on 9/2/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//
//  Usage:
//
//  ```
//  let node = MeshLineNode()
//  let material = MeshLineMaterial()
//  var _vertices: [SCNVector3] = []
//  for i in 0..<360 {
//    let phase = Float(i) / Float(360)
//    let x = CGFloat(i) / 300.0;
//    let y = CGFloat(sin( phase * 20.0 ) * 0.1);
//    let z = CGFloat(cos( phase * 30.0) * 1.0 );
//    _vertices.append(SCNVector3(x: x, y: y, z: z))
//  }
//  node.setVertices(vertices: _vertices)
//  node.geometry?.materials = [material]
//  ```



import SceneKit

public class MeshLineNode: SCNNode {
    
    public struct Attribute {
        var position: float3!   // => Semantic.vertex
        var previous: float3!   // => Semantic.normal
        var next: float3!       // => Semantic.tangent
        var uv: float2!         // => Semantic.vertex
        var misc: float3!       // => Semantic.boneWeights
    }
        
    public override init() {
        super.init()
    }
    
    public func setVertices(vertices: [SCNVector3]) {
        let mat = geometry?.firstMaterial
        process(vertices)
        if mat != nil {
            geometry?.firstMaterial = mat
        }
    }
    
    private func process(_ vertices: [SCNVector3]) {
        
        let l = vertices.count
        var indices: [UInt16] = []
        var attributes: [Attribute] = []
        
        vertices.enumerated().forEach { (arg) in
            
            let (index, v) = arg
            
            let c = Float(index) / Float(l)
            if l - 1 > index {
                let n = index * 2
                let t1: [UInt16] = [UInt16(n), UInt16(n + 1), UInt16(n + 2)]
                let t2: [UInt16] = [UInt16(n + 2), UInt16(n + 1), UInt16(n + 3)]

                indices.append(contentsOf: t1)
                indices.append(contentsOf: t2)
            }
            for k in 0..<2 {
                let position = v
                let counter = c
                let side = Float(k == 0 ? 1 : -1)
                let width: Float = 1
                let uv = float2(Float(Float(index) / Float(l - 1)), k == 0 ? 0 : 1)
                let previous = vertices[index == 0 ? (vertices[0] == vertices[l - 1] ? l - 2 : 0) : index]
                let next = vertices[index < l - 1 ? index + 1 : vertices[l - 1] == vertices[0] ? 1 : l - 1]
 
                attributes.append(Attribute(position: float3(Float(position.x), Float(position.y), Float(position.z)),
                                            previous: float3(Float(previous.x), Float(previous.y), Float(previous.z)),
                                            next: float3(Float(next.x), Float(next.y), Float(next.z)),
                                            uv: uv,
                                            misc: float3(counter, side, width)))
            }
        }
        
        let baseData = NSData.init(bytes: &attributes, length: attributes.count * MemoryLayout<Attribute>.stride)
        let data = Data(referencing: baseData)
        let count = l * 2
        let floatSize = MemoryLayout<Float>.size
        let stride = MemoryLayout<Attribute>.stride
        let indicesData_ = NSData.init(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count)
        let indicesData = Data.init(referencing: indicesData_)
        let vertexSource    = SCNGeometrySource(data: data, semantic: .vertex, vectorCount: count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: floatSize, dataOffset: 0, dataStride: stride)
        let previousSource  = SCNGeometrySource(data: data, semantic: .normal, vectorCount: count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: floatSize, dataOffset: offsets[1], dataStride: stride)
        let nextSource      = SCNGeometrySource(data: data, semantic: .tangent, vectorCount: count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: floatSize, dataOffset: offsets[2], dataStride: stride)
        let tcoordSource    = SCNGeometrySource(data: data, semantic: .texcoord, vectorCount: count, usesFloatComponents: true, componentsPerVector: 2, bytesPerComponent: floatSize, dataOffset: offsets[3], dataStride: stride)
        let miscSource      = SCNGeometrySource(data: data, semantic: .boneWeights, vectorCount: count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: floatSize, dataOffset: offsets[4], dataStride: stride)
        let indicesSource = SCNGeometryElement.init(data: indicesData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<UInt16>.size)
        let sources = [vertexSource, tcoordSource, previousSource, nextSource, miscSource]
        geometry = SCNGeometry.init(sources: sources, elements: [indicesSource])
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // There's no `offsetOf` in swift.
    // Here, basically calculating the offsets by its position in address
    lazy var offsets: [Int] = {
        
        var a = Attribute()
        var offsets: [Int] = []
        var start: Int = 0
        
        withUnsafePointer(to: &a) {
            start = Int(bitPattern: $0)
        }

        withUnsafePointer(to: &a.position) {
            offsets.append(Int(bitPattern: $0) - start)
        }
        withUnsafePointer(to: &a.previous) {
            offsets.append(Int(bitPattern: $0) - start)
        }
        withUnsafePointer(to: &a.next) {
            offsets.append(Int(bitPattern: $0) - start)
        }
        withUnsafePointer(to: &a.uv) {
            offsets.append(Int(bitPattern: $0) - start)
        }
        withUnsafePointer(to: &a.misc) {
            offsets.append(Int(bitPattern: $0) - start)
        }
        
        return offsets
    }()
}

extension SCNVector3 {
    static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
