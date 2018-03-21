//
//  UtilTests.swift
//  UnsplasherTests
//
//  Created by Adrián Bouza Correa on 23/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class UtilTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHexColor() {
        for hex in ["#ff004E", "#77D2A1", "88AC2B"] {
            let color = UIColor(hex: hex)
            XCTAssertNotNil(color, "Could not obtain color.")
        }
    }
    
    func testFindLinks() {
        let linkSample = """
<https://api.unsplash.com/photos?page=1>; rel="first",
<https://api.unsplash.com/photos?page=2>; rel="prev",
<https://api.unsplash.com/photos?page=346>; rel="last",
<https://api.unsplash.com/photos?page=4>; rel="next"
"""
        let links = "(?<=\\<)(.*?)(?=\\>)".matches(in: linkSample)
        let keys = "(?<=rel=\")(.*?)(?=\\\")".matches(in: linkSample)
        
        XCTAssertTrue(links.count == 4 && links.count == keys.count, "Incorrect number of links")
    }
    
}
