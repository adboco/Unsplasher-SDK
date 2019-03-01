//
//  PhotoRequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class PhotoRequestsTests: RequestsTests {
    
    // MARK: - Photos
    
    func testGetPhotoList() {
        let expectation = self.expectation(description: "Photos")
        
        Unsplash.shared.photos.photos(page: 1, perPage: 10) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetPhotoById() {
        let expectation = self.expectation(description: "Photo")
        
        let id = "2PODhmrvLik"
        
        Unsplash.shared.photos.photo(id: id, width: 300, height: 300) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photo with id: \(id)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testUpdatePhoto() {
        let expectation = self.expectation(description: "Photo Update")
        
        let id = "Hc8z9TzyVt0"
        
        Unsplash.shared.photos.photo(id: id) { result in
            guard result.isSuccess, var photo = result.value else {
                XCTFail("Could not retrieve photo with id: \(id)")
                return
            }
            photo.location?.country = "Spain"
            photo.location?.city = "A Coruña"
            photo.exif?.make = "Nikon"
            photo.exif?.model = "D520"
            Unsplash.shared.photos.update(photo, completion: { result in
                XCTAssertTrue(result.isSuccess, "Error updating photo with id: \(id)")
                expectation.fulfill()
            })
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetRandomPhotos() {
        let expectation = self.expectation(description: "Random Photos")
        
        Unsplash.shared.photos.randomPhotos(
            collectionIds: [232, 547, 89, 555],
            featured: false,
            width: 600,
            height: 400,
            orientation: .landscape,
            count: 4) { result in
                XCTAssertTrue(result.isSuccess, "Error getting random photos.")
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetRandomPhoto() {
        let expectation = self.expectation(description: "Random Photo")
        
        Unsplash.shared.photos.randomPhoto(
            collectionIds: [232, 547, 89, 555],
            featured: false,
            width: 600,
            height: 400,
            orientation: .landscape) { result in
                XCTAssertTrue(result.isSuccess, "Error getting random photo.")
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
    
    func testGetPhotoDownloadLink() {
        let expectation = self.expectation(description: "Photo Download Link")
        
        let id = "2PODhmrvLik"
        
        Unsplash.shared.photos.downloadLink(id: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting donwload link of photo with id: \(id)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.Requests.defaultTimeout)
    }
}
