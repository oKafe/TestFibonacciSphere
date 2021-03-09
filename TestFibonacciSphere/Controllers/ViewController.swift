//
//  ViewController.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 08.03.2021.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var debugLabel: UILabel!
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
    
    private var passedPointsInddexes = [String]() {
        didSet {
            debugLabel.text = passedPointsInddexes.joined(separator: ", ")
        }
    }
    
    private var lastPointPassed: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    private func setupSession() {
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        configureScene()
        sceneView.session.run(configuration)
    }
    
    private func configureScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    private func getSphereNode(position: SCNVector3, _ pointNumber: Int) -> SCNNode {
        let ball = SCNSphere(radius: 0.04)
        ball.firstMaterial?.diffuse.contents = UIColor.red
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
    
    private func showRing() {
        let ring = SCNTorus(ringRadius: 0.007, pipeRadius: 0.0003)
        ring.materials.first?.diffuse.contents = UIColor.blue
        let ringNode = SCNNode(geometry: ring)
        ringNode.name = "ring"
        ringNode.position = SCNVector3(0, 0, -0.2)
        ringNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(90), 0, 0)
        self.sceneView.pointOfView?.addChildNode(ringNode)
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
            fov == 0 else {
            return
        }
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
            pointsService = PointsService(fov: fov, overlapping: 0.2, positionScale: 1.5)
            showRing()
        }
    }
    
    func hittedNode(_ point: CGPoint, renderer: SCNSceneRenderer) -> SCNNode? {
        var options: [SCNHitTestOption : Any] = [:]
        if #available(iOS 11.0, *) {
            options = [SCNHitTestOption.searchMode: 1]
        }
        let hitTests = renderer.hitTest(point, options: options)
        let result = hitTests.first { (hitTestResult) -> Bool in
            return (hitTestResult.node.name?.contains("sphere") ?? false)
        }
        result?.node.geometry?.materials.first?.diffuse.contents = UIColor.blue
        return result?.node
    }
    
    private func detectPoint(_ renderer: SCNSceneRenderer) {
        guard let scene = renderer as? ARSCNView else { return }
        guard let ring = scene.pointOfView?.childNodes
            .filter ({ return $0.name == "ring" }).first else { return }
        let ringPoint = sceneView.projectPoint(ring.worldPosition).cgPoint
        guard let hittedNode = hittedNode(ringPoint, renderer: renderer) else { return }
        if let lastPoint = lastPointPassed {
            drawLine(from: lastPoint, to: hittedNode)
        }
        lastPointPassed = hittedNode
        let nodeName = hittedNode.name ?? "No sphere name"
        if !passedPointsInddexes.contains(nodeName) {
            passedPointsInddexes.append(hittedNode.name ?? "No sphere name")
        }
    }
    
    private func drawLine(from: SCNNode, to: SCNNode) {
        let cylinderLine = SCNGeometry.cylinderLine(from: from.position, to: to.position, segments: 3)
        sceneView.scene.rootNode.addChildNode(cylinderLine)
    }
    
}


extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.getFov(renderer: renderer, time: time)
            self.detectPoint(renderer)
        }
        
        
    }
}
