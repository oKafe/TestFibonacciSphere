//
//  PointsService.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 08.03.2021.
//

import Foundation
import ARKit

class PointsService {
    private let fov: Double
    private let overlapping: Double
    private let pointsAngles = PointAngles()
    private var viewPoints = [ViewPoint3]()
    private var pointsPositions = [SCNVector3]()
    private let positionScale: Double
    
    init(fov: Double, overlapping: Double, positionScale: Double) {
        self.fov = fov
        self.overlapping = overlapping
        self.positionScale = positionScale
        self.viewPoints = self.getAllViewPoints()
        self.pointsPositions = self.viewPoints.map { SCNVector3($0.x * positionScale, $0.y * positionScale, $0.z * positionScale) }
    }
    
    
    func getAllPoints() -> [(SCNVector3, Int)] {
        return pointsPositions.enumerated().map { ($0.element, $0.offset) }
    }
    
    private func getAllViewPoints() -> [ViewPoint3] {
        return pointsAngles.getAllViewPoints(fov: fov, overlapping: overlapping)
    }
    
}
