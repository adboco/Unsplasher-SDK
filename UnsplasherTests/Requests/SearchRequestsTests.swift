//
//  SearchRequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class SearchRequestsTests: RequestsTests {
    
    // MARK: - Search
    
    func testSearch() {
        let photosExpectation = self.expectation(description: "Search Photos")
        let collectionsExpectation = self.expectation(description: "Search Collections")
        let usersExpectation = self.expectation(description: "Search Users")
        
        Unsplash.shared.search.photos(query: "dog") { result in
            XCTAssertTrue(result.isSuccess, "Error searching photos.")
            photosExpectation.fulfill()
        }
        
        Unsplash.shared.search.collections(query: "mountain") { result in
            XCTAssertTrue(result.isSuccess, "Error searching collections.")
            collectionsExpectation.fulfill()
        }
        
        Unsplash.shared.search.users(query: "ari spada") { result in
            XCTAssertTrue(result.isSuccess, "Error searching users.")
            usersExpectation.fulfill()
        }
        
        wait(for: [photosExpectation, collectionsExpectation, usersExpectation], timeout: TestConstants.Requests.defaultTimeout)
    }
}
