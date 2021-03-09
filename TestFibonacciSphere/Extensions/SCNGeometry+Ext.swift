//
//  SCNGeometry+Ext.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 08.03.2021.
//

import Foundation
import SceneKit

extension SCNGeometry {
    class func line(from: SCNVector3, to: SCNVector3) -> SCNGeometry {
        let sources = SCNGeometrySource(vertices: [from, to])
        let indexes: [UInt32] = [0, 1]
        
        let elements = SCNGeometryElement(indices: indexes, primitiveType: .line)
        return SCNGeometry(sources: [sources], elements: [elements])
    }
    
    class func cylinderLine(from: SCNVector3,
                                  to: SCNVector3,
                            segments: Int) -> SCNNode {

            let x1 = from.x
            let x2 = to.x

            let y1 = from.y
            let y2 = to.y

            let z1 = from.z
            let z2 = to.z

            let distance =  sqrtf( (x2-x1) * (x2-x1) +
                                   (y2-y1) * (y2-y1) +
                                   (z2-z1) * (z2-z1) )

            let cylinder = SCNCylinder(radius: 0.005,
                                       height: CGFloat(distance))

            cylinder.radialSegmentCount = segments

            cylinder.firstMaterial?.diffuse.contents = UIColor.green

            let lineNode = SCNNode(geometry: cylinder)

            lineNode.position = SCNVector3(x: (from.x + to.x) / 2,
                                           y: (from.y + to.y) / 2,
                                           z: (from.z + to.z) / 2)

            lineNode.eulerAngles = SCNVector3(Float.pi / 2,
                                              acos((to.z-from.z)/distance),
                                              atan2((to.y-from.y),(to.x-from.x)))

            return lineNode
    }
}
