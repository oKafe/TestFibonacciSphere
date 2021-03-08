//
//  ViewController.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 08.03.2021.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    private let timeOfCalculateFov: TimeInterval = 1
    private var fov: Double = 0
    private var fovArray = [Float]()
    private var startTimeForCalculateFov: TimeInterval = 0
    private var pointsService: PointsService! {
        didSet {
            showSpherePoints()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }
    
    private func getSphereNode(position: SCNVector3, _ pointNumber: Int) -> SCNNode {
        let ball = SCNSphere(radius: 0.04)
        ball.firstMaterial?.diffuse.contents = UIColor.black
        let ballNode = SCNNode(geometry: ball)
        ballNode.isHidden = false
        ballNode.name = "sphere\(pointNumber)"
        ballNode.position = position
        return ballNode
    }
    
    private func addSpherePoint(_ position: SCNVector3, pointNumber: Int) {
        let sphereNode = getSphereNode(position: position, pointNumber)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    private func showSpherePoints() {
        let spheres = pointsService.getAllPoints()
        spheres.forEach { (position, index) in
            addSpherePoint(position, pointNumber: index)
        }
    }
    
    private func getFov(renderer: SCNSceneRenderer, time: TimeInterval) {
        guard let scene = renderer as? ARSCNView,
            let camera = scene.session.currentFrame?.camera,
            fov == 0 else { return }
        if startTimeForCalculateFov == 0 {
            startTimeForCalculateFov = time
        }
        
        if startTimeForCalculateFov + timeOfCalculateFov > time {
            let imageResolution = camera.imageResolution
            let intrinsics = camera.intrinsics
            
            let wFovDegrees = 2 * atan(Float(imageResolution.width)/(2 * intrinsics[1,1])) * 180/Float.pi
            let hFovDegrees = 2 * atan(Float(imageResolution.height)/(2 * intrinsics[1,1])) * 180/Float.pi
            let minFov = min(wFovDegrees, hFovDegrees)
            fovArray.append(minFov)
        } else {
            let average = fovArray.reduce(0, +) / Float(fovArray.count)
            fov = Double(ceil(average))
            self.pointsService = PointsService(fov: fov, overlapping: 20, positionScale: 2.0)
        }
    }
    
}


extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        getFov(renderer: renderer, time: time)
    }
}
