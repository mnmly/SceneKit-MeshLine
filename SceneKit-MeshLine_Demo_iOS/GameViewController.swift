//
//  GameViewController.swift
//  SceneKit-MeshLine_Demo_iOS
//
//  Created by Hiroaki Yamane on 9/5/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit


class GameViewController: UIViewController {
    
    var lineNodes: [MeshLineNode]! = []
    var lineMaterials: [MeshLineMaterial]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        for i in 0..<5 {
            let node = MeshLineNode()
            let material = MeshLineMaterial()
            material.uniform.lineWidth = Float(i * 2 + 3)
            material.uniform.resolution = float2(Float(view.bounds.width), Float(view.bounds.height))
            material.update()
            var _vertices: [SCNVector3] = []
            for i in 0..<360 {
                let phase = Float(i) / Float(360)
                let x: Float = (Float(i) / 300.0 - 0.5) * 4.0;
                let y: Float = Float(sin( phase * 20.0 ) * 0.1);
                let z: Float = Float(cos( phase * 30.0) * 1.0 );
                _vertices.append(SCNVector3(x: x, y: y, z: z))
            }
            node.setVertices(vertices: _vertices)
            node.geometry?.materials = [material]
            node.position.y += Float(i) * 1.0 - 2.5
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
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
     
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        scnView.delegate = self
        scnView.loops = true
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
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
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        lineNodes.enumerated().forEach { (index, node) in
            var _vertices: [SCNVector3] = []
            for i in 0..<360 {
                let phase = Float(i) / Float(360)
                let x = (Float(i) / 300.0 - 0.5) * 4.0;
                let y = Float(sin( phase * 50.0 + Float(time) * 5.2) * 0.1);
                let z = Float(cos( phase * 5.0 + Float(time) * 5.0 ) * 0.5 );
                _vertices.append(SCNVector3(x: x, y: y, z: z))
            }
            lineNodes[index].setVertices(vertices: _vertices)
        }
    }
}
