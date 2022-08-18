//
//  ViewController.swift
//  AR Ruler
//
//  Created by OBS 53 on 11/08/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var pointNodes = [SCNNode]()
    var textNode = SCNNode()

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    func addPoint(withLocation location: ARHitTestResult){
        let point = SCNSphere(radius: 0.003)
        
        let getMaterial = SCNMaterial()
        getMaterial.diffuse.contents = UIColor.red
        
        point.materials = [getMaterial]
        
        let pointNode = SCNNode(geometry: point)
        
        pointNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y,
            z: location.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(pointNode)

        pointNodes.append(pointNode)
        
        if pointNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = pointNodes[0]
        let end = pointNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        addText(text: "\(abs(distance*100))", atPosition: end.position)
         
        distanceLabel.text = "Distance: \(abs(distance*100))cm"
    }
    
    func addText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.05, z: position.z)
        
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
    
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    // MARK: - ARSCNViewDelegate

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if pointNodes.count >= 2 {
            for points in pointNodes {
                points.removeFromParentNode()
                textNode.removeFromParentNode()
            }
            pointNodes = [SCNNode]()
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = result.first {
                addPoint(withLocation: hitResult)
            }
        }
    }
    
}
 
