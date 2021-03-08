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
}
