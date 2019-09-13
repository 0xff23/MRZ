//
//  MRZTests.swift
//  MRZTests
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import XCTest
@testable import MRZ

class MRZTests: XCTestCase {
  
  let correctBarCode = "P<USAROGGER<<MICHAEL<<<<<<<<<<<BISHOP><<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  let incorrectCountryCode = "P<RUSROGGER<<MICHAEL<<<<<<<<<<<BISHOP><<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  let noPassportCode = "B<USAROGGER<<MICHAEL<<<<<<<<<<<BISHOP><<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
      
      
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
