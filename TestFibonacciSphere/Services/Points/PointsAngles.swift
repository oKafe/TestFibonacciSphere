//
//  PointsAngles.swift
//  TestFibonacciSphere
//
//  Created by Andy Orphan on 08.03.2021.
//

import Foundation
import SceneKit


struct PointAngles {
    
    func getAllViewPoints(fov: Double, overlapping: Double) -> [ViewPoint3] {
        guard overlapping <= 1.0 || overlapping >= 0.0 else {
            fatalError("Overlapping must be from 0.0 to 1.0")
        }
        let numberOfPointsAtEquator = Int(ceil(360/((1.0 - overlapping) * fov)))
        let numberOfAllPoints = numberOfPointsAtEquator * numberOfPointsAtEquator / 2
        let point3Array = getFibonachiPoints(numberOfAllPoints)
        return viewPoints3(from: point3Array)
    }
}


private extension PointAngles {
    func getFibonachiPoints(_ numberOfPoints: Int) -> [Point3] {
        let offset = 2.0 / Double(numberOfPoints)
        let increment = Double.pi * (3.0 - sqrt(5.0))
        return Array(repeating: 0, count: numberOfPoints).indices
            .map { index -> Point3 in
                let y   = ((Double(index) * offset) - 1) + (offset / 2)
                let r   = sqrt(1 - pow(y, 2))
                let phi = Double((index + 1) % numberOfPoints) * increment
                let x   = cos(phi) * r
                let z   = sin(phi) * r
                return Point3(x: x, y: y, z: z)
        }
    }
    
    func rotationAroundY(_ angle: Double) -> [Double] {
        return [cos(angle),
                0.0,
                sin(angle),
                0.0,
                1.0,
                0.0,
                -sin(angle),
                0.0,
                cos(angle)]
    }
    
    func reprojPoint(rmat: [Double], pt: Point3) -> Point3 {
        let x = rmat[0] * pt.x + rmat[1] * pt.y + rmat[2] * pt.z
        let y = rmat[3] * pt.x + rmat[4] * pt.y + rmat[5] * pt.z
        let z = rmat[6] * pt.x + rmat[7] * pt.y + rmat[8] * pt.z
        return Point3(x: x, y: y, z: z)
    }
    
    func viewPoints3(from points: [Point3]) -> [ViewPoint3] {
        let yaw = -Double.pi * 0.5
        return points.map { pt -> ViewPoint3 in
            var x = -pt.x
            var y = -pt.y
            var z = -pt.z
            let pitch = -atan2(x, -z)
            let ry_inv = rotationAroundY(-pitch)
            let rpt = reprojPoint(rmat: ry_inv, pt: pt)
            x = -rpt.x
            y = -rpt.y
            z = -rpt.z
            let roll = atan2(y, -z)
            return ViewPoint3(pitch: pitch, roll: roll, yaw: yaw, x: -pt.x, y: -pt.y, z: -pt.z)
        }
    }
    
    
}
