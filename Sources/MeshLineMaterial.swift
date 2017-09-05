//
//  MeshLineMaterial.swift
//  AnimationDemo
//
//  Created by Hiroaki Yamane on 9/5/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import SceneKit

public class MeshLineMaterial: SCNMaterial {
    
    // TODO: texture props.
    
    public var uniform: Uniform! {
        didSet {
            needsUpdate = true
        }
    }
    
    public var needsUpdate = true
    
    public struct Uniform {
        public var lineWidth: Float = 1.0
        // map
        public var useMap: Float = 0
        public var useAlphaMap: Float = 0
        // alphaMap
        public var color: float4 = float4(1, 1, 1, 1)
        public var opacity: Float = 1.0
        public var resolution: float2 = float2(1, 1)
        public var sizeAttenuation: Float = 1
        public var near: Float = 1
        public var far: Float = 1
        public var dashArray: float2 = float2(0, 0)
        public var useDash: Float = 0
        public var visibility: Float = 1
        public var alphaTest: Float = 0
        public var repeating: float2 = float2(1, 1)
    }

    
    public override init() {
        super.init()
        uniform = Uniform()
        program = setupProgram()
        isDoubleSided = true
        update()
    }
    
    private func setupProgram() -> SCNProgram {
        let program = SCNProgram()
        program.vertexFunctionName = "vertexFunction"
        program.fragmentFunctionName = "fragmentFunction"
        return program
    }
    
    public func update() {
        if needsUpdate {
            let uniformData = Data.init(bytes: &uniform, count: MemoryLayout<Uniform>.stride)
            setValue(uniformData, forKey: "uniforms")
        }
        needsUpdate = false
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
