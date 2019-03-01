//
//  CollectionRequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class CollectionRequestsTests: RequestsTests {
    
    // MARK: - Collections
    
    func testGetCollections() {
        let anyExpectation = self.expectation(description: "Collections")
        let curatedExpectation = self.expectation(description: "Curated Collections")
        let featuredExpectation = self.expectation(description: "Featured Collections")
        
        Unsplash.shared.collections.collections { result in
            XCTAssertTrue(result.isSuccess, "Error getting collections.")
            anyExpectation.fulfill()
        }
        
        Unsplash.shared.collections.collections(list: .curated) { result in
            XCTAssertTrue(result.isSuccess, "Error getting curated collections.")
            curatedExpectation.fulfill()
        }
        
        Unsplash.shared.collections.collections(list: .featured) { result in
            XCTAssertTrue(result.isSuccess, "Error getting featured collections.")
            featuredExpectation.fulfill()
        }
        
        wait(for: [anyExpectation, curatedExpectation, featuredExpectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetCollectionById() {
        let expectation = self.expectation(description: "Collection")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.collection(id: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting collection with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetCollectionPhotos() {
        let expectation = self.expectation(description: "Collection Photos")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.photos(in: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photos of collection: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetRelatedCollections() {
        let expectation = self.expectation(description: "Related Collections")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.collections(relatedWith: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting collections related with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testCreateDeleteCollection() {
        let expectation = self.expectation(description: "Create and Delete Collection")
        
        Unsplash.shared.collections.create(title: "Collection", isPrivate: false) { result in
            switch result {
            case .success(let collection):
                Unsplash.shared.collections.delete(id: collection.id, completion: { result in
                    XCTAssertTrue(result.isSuccess, "Error deleting collection.")
                    expectation.fulfill()
                })
                return
            default:
                break
            }
            XCTAssertTrue(result.isSuccess, "Error creating collection.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testAddPhotoToCollection() {
        let expectation = self.expectation(description: "Add Photo to Collection")
        
        let photoId = "dtCTfjTEOgg"
        let id: UInt32 = 4378364
        
        Unsplash.shared.collections.add(photoId: photoId, to: id) { result in
            XCTAssertTrue(result.isSuccess, "Error adding photo (\(photoId)) to collection with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testRemovePhotoFromCollection() {
        let expectation = self.expectation(description: "Add Photo to Collection")
        
        let photoId = "dtCTfjTEOgg"
        let id: UInt32 = 4378364
        
        Unsplash.shared.collections.remove(photoId: photoId, from: id) { result in
            XCTAssertTrue(result.isSuccess, "Error removing photo (\(photoId)) from collection with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
}
