//
//  CalculatorBrainTests.swift
//  Calculator
//
//  Created by Floyd Gantt on 2/17/16.
//  Copyright © 2016 Edansys. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorBrainTests: XCTestCase {
    
    var brain = CalculatorBrain()
    
    override func setUp() {
        super.setUp()
        brain = CalculatorBrain()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func compare(a: Double, b: Double, delta: Double) -> Bool {
        return abs(a - b) < delta
    }
    
    func testDescription() {
        // cos(10)
        XCTAssertEqual(brain.pushOperand(10)!, 10)
        XCTAssertTrue(compare(brain.performOperation("cos")!, b: -0.839, delta: 0.1))
        XCTAssertEqual(brain.description, "cos(10)")
        
        
        // 3 ↩︎ 5 √ + √ 6 ÷
        brain.clear()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertTrue(compare(brain.performOperation("√")!, b: 2.236, delta: 0.001))
        brain.performOperation("+")
        brain.performOperation("√")
        brain.pushOperand(6)
        brain.performOperation("÷")
        XCTAssertEqual(brain.description, "√(3 + √(5)) ÷ 6")
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
