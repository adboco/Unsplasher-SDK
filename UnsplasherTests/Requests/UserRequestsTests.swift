//
//  UserRequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class UserRequestsTests: RequestsTests {
    
    // MARK: - Users
    
    func testGetProfile() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.currentUser.profile { result in
            XCTAssertTrue(result.isSuccess, "Error getting profile.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testUpdateProfile() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.currentUser.profile { result in
            switch result {
            case .success(var user):
                user.firstName = "Adrián"
                Unsplash.shared.currentUser.update(user, completion: { (result) in
                    XCTAssertTrue(result.isSuccess, "Error updating profile.")
                    expectation.fulfill()
                })
            case .failure(let error):
                XCTAssert(false, "Error getting profile: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetUser() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.users.user("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user profile.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetUserPortfolio() {
        let expectation = self.expectation(description: "Portfolio")
        
        Unsplash.shared.users.portfolio(by: "ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user portfolio.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetUserPhotos() {
        let expectation = self.expectation(description: "User's Photos")
        
        Unsplash.shared.users.photos.by("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user's photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetPhotosLikedByUser() {
        let expectation = self.expectation(description: "Liked Photos")
        
        Unsplash.shared.users.photos.liked(by: "ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting liked photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetUserCollections() {
        let expectation = self.expectation(description: "User's Collections")
        
        Unsplash.shared.users.collections.by("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user's collections.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
}
