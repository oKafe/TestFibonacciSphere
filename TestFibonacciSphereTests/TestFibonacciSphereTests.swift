//
//  TestFibonacciSphereTests.swift
//  TestFibonacciSphereTests
//
//  Created by Andy Orphan on 08.03.2021.
//

import XCTest
@testable import TestFibonacciSphere

class TestFibonacciSphereTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPointsCount() throws {
        let pointsService = PointsService(fov: 52.0, overlapping: 0.2, positionScale: 1.5)
        let pointsCount = pointsService.getAllPointsCount()
        XCTAssert(pointsCount == 40)
    }

    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
