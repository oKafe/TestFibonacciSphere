//
//  SCNVector3+Ext.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 09.03.2021.
//

import Foundation
import SceneKit

extension SCNVector3 {
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
