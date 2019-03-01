//
//  StatisticsRequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class StatisticsRequestsTests: RequestsTests {
    
    // MARK: - Statistics
    
    func testGetPhotoStatistics() {
        let expectation = self.expectation(description: "Photo Statistics")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.statistics(photoId: photoId, resolution: .days) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photo statistics.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testLikePhoto() {
        let expectation = self.expectation(description: "Like Photo")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.like(id: photoId) { result in
            XCTAssertTrue(result.isSuccess, "Error liking photo.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testUnlikePhoto() {
        let expectation = self.expectation(description: "Unlike Photo")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.unlike(id: photoId) { result in
            XCTAssertTrue(result.isSuccess, "Error unliking photo.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetUserStatistics() {
        let expectation = self.expectation(description: "User Statistics")
        
        let username = "ari_spada"
        
        Unsplash.shared.users.statistics(username: username) { result in
            XCTAssertTrue(result.isSuccess, "Error getting user statistics.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
}
