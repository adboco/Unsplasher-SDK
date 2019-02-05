//
//  UnsplasherTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza Correa on 19/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class UnsplasherTests: XCTestCase {
    
    let defaultTimeout: Double = 10
    
    let appId = "YOUR_APPLICATION_ID"
    let secret = "YOUR_SECRET"
    let token = "YOUR_ACCESS_TOKEN"
    
    override func setUp() {
        super.setUp()
        
        Unsplash.configure(appId: appId, secret: secret, scopes: Unsplash.PermissionScope.all)
        let accessToken = AccessToken(token: token, tokenType: "bearer", scope: Unsplash.PermissionScope.all.map({ $0.rawValue }).joined(separator: " "))
        Unsplash.shared.accessToken = accessToken
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Requests
    
    // MARK: - Users
    
    func testGetProfile() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.currentUser.profile { result in
            XCTAssertTrue(result.isSuccess, "Error getting profile.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testUpdateProfile() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.currentUser.profile { result in
            switch result {
            case .success(var user):
                user.firstName = "Name"
                Unsplash.shared.currentUser.update(user, completion: { (result) in
                    XCTAssertTrue(result.isSuccess, "Error updating profile.")
                    expectation.fulfill()
                })
            case .failure(let error):
                XCTAssert(false, "Error getting profile: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetUser() {
        let expectation = self.expectation(description: "User")
        
        Unsplash.shared.users.user("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user profile.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetUserPortfolio() {
        let expectation = self.expectation(description: "Portfolio")
        
        Unsplash.shared.users.portfolio(by: "ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user portfolio.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetUserPhotos() {
        let expectation = self.expectation(description: "User's Photos")
        
        Unsplash.shared.users.photos.by("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user's photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetPhotosLikedByUser() {
        let expectation = self.expectation(description: "Liked Photos")
        
        Unsplash.shared.users.photos.liked(by: "ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting liked photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetUserCollections() {
        let expectation = self.expectation(description: "User's Collections")
        
        Unsplash.shared.users.collections.by("ari_spada") { result in
            XCTAssertTrue(result.isSuccess, "Error getting user's collections.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    // MARK: - Photos
    
    func testGetPhotoList() {
        let expectation = self.expectation(description: "Photos")
        
        Unsplash.shared.photos.photos { result in
            XCTAssertTrue(result.isSuccess, "Error getting photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetPhotoById() {
        let expectation = self.expectation(description: "Photo")
        
        let id = "2PODhmrvLik"
        
        Unsplash.shared.photos.photo(id: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photo with id: \(id)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetRandomPhotos() {
        let expectation = self.expectation(description: "Random Photos")
        
        Unsplash.shared.photos.randomPhotos { result in
            XCTAssertTrue(result.isSuccess, "Error getting random photos.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetRandomPhoto() {
        let expectation = self.expectation(description: "Random Photo")
        
        Unsplash.shared.photos.randomPhoto { result in
            XCTAssertTrue(result.isSuccess, "Error getting random photo.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetPhotoDownloadLink() {
        let expectation = self.expectation(description: "Photo Download Link")
        
        let id = "2PODhmrvLik"
        
        Unsplash.shared.photos.downloadLink(id: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting donwload link of photo with id: \(id)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testUploadPhoto() {
        let expectation = self.expectation(description: "Photo Upload")
        
        let photo = UIImage("downloads")
        
        Unsplash.shared.photos.upload(photo) { result in
            XCTAssertTrue(result.isSuccess, "Error uploading photo")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    // MARK: - Statistics
    
    func testGetPhotoStatistics() {
        let expectation = self.expectation(description: "Photo Statistics")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.statistics(photoId: photoId) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photo statistics.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testLikePhoto() {
        let expectation = self.expectation(description: "Like Photo")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.like(id: photoId) { result in
            XCTAssertTrue(result.isSuccess, "Error liking photo.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testUnlikePhoto() {
        let expectation = self.expectation(description: "Unlike Photo")
        
        let photoId = "2PODhmrvLik"
        
        Unsplash.shared.photos.unlike(id: photoId) { result in
            XCTAssertTrue(result.isSuccess, "Error unliking photo.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetUserStatistics() {
        let expectation = self.expectation(description: "User Statistics")
        
        let username = "ari_spada"
        
        Unsplash.shared.users.statistics(username: username) { result in
            XCTAssertTrue(result.isSuccess, "Error getting user statistics.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
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
        
        wait(for: [photosExpectation, collectionsExpectation, usersExpectation], timeout: defaultTimeout)
    }
    
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
        
        wait(for: [anyExpectation, curatedExpectation, featuredExpectation], timeout: defaultTimeout)
    }
    
    func testGetCollectionById() {
        let expectation = self.expectation(description: "Collection")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.collection(id: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting collection with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetCollectionPhotos() {
        let expectation = self.expectation(description: "Collection Photos")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.photos(in: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting photos of collection: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testGetRelatedCollections() {
        let expectation = self.expectation(description: "Related Collections")
        
        let id: UInt32 = 206
        
        Unsplash.shared.collections.collections(relatedWith: id) { result in
            XCTAssertTrue(result.isSuccess, "Error getting collections related with id: \(id).")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
    func testCreateDeleteCollection() {
        let expectation = self.expectation(description: "Create and Delete Collection")
        
        Unsplash.shared.collections.create(title: "My Collection", isPrivate: true) { result in
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
        
        wait(for: [expectation], timeout: defaultTimeout)
    }
    
}

private extension Result {
    
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .success(_):
            return false
        case .failure(_):
            return true
        }
    }
    
}
