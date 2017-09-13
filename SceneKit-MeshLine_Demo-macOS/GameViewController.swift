//
//  GameViewController.swift
//  SceneKit-MeshLine_Demo
//
//  Created by Hiroaki Yamane on 9/5/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    var lineNodes: [MeshLineNode]! = []
    var lineMaterials: [MeshLineMaterial]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        for i in 0..<5 {
            let node = MeshLineNode()
            let material = MeshLineMaterial()
            material.uniform.lineWidth = 2.0 //Float(i * 2 + 3)
            material.update()
            var _vertices: [SCNVector3] = []
            for i in 0..<360 {
                let phase = Float(i) / Float(360)
                let x = (CGFloat(i) / 300.0 - 0.5) * 100.0;
                let y = CGFloat(sin( phase * 20.0 ) * 5.1);
                let z = CGFloat(cos( phase * 30.0) * 1.0 );
                _vertices.append(SCNVector3(x: x, y: y, z: z))
            }
            node.setVertices(vertices: _vertices)
            node.geometry?.materials = [material]
            node.position.y += (CGFloat(i) * 1.0 - 2.5) * 10.0
            lineNodes.append(node)
            lineMaterials.append(material)
            scene.rootNode.addChildNode(node)
        }
        
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        ambientLightNode.runAction(SCNAction.repeat(SCNAction.moveBy(x: 10.0, y: 0, z: 0, duration: 0.1), count: 1000))
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
        scnView.delegate = self
        scnView.loops = true
        NotificationCenter.default.addObserver(self, selector: #selector(onResize), name: NSWindow.didResizeNotification, object: nil)
    }

    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
    
    @objc func onResize() {
        lineMaterials.forEach { (material) in
            material.uniform.resolution = float2(Float(self.view.bounds.size.width), Float(self.view.bounds.size.height))
            material.update()
        }
    }
}


extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        lineNodes.enumerated().forEach { (arg) in
            let (index, node) = arg
            lineMaterials[index].uniform.lineWidth = (sin( Float(time) * 1.0 ) + 1.0) / 2.0 * Float(index + 1) / 5.0 * 2.0;
            lineMaterials[index].update()
        }
    }
}
