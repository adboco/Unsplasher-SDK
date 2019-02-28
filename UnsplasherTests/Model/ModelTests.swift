//
//  ModelTests.swift
//  UnsplasherTests
//
//  Created by Adrián Bouza Correa on 21/2/18.
//  Copyright © 2018 adboco. All rights reserved.
//

import XCTest
import SwiftKeychainWrapper
@testable import Unsplasher

class ModelTests: XCTestCase {
    
    private let decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        return jsonDecoder
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func decode<T:Codable>(modelType: T.Type, from resource: String) -> T? {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.url(forResource: resource, withExtension: "json")!
        let data = try? Data(contentsOf: path, options: .mappedIfSafe)
        
        return try? decoder.decode(modelType, from: data!)
    }
    
    // MARK: - User
    
    func testDecodeUser() {
        XCTAssertNotNil(self.decode(modelType: User.self, from: "user"), "Could not decode user.")
    }
    
    // MARK: - Photos
    
    func testDecodePhoto() {
        let photo = self.decode(modelType: Photo.self, from: "photo")
        _ = photo?.color
        XCTAssertNotNil(photo, "Could not decode photo.")
    }
    
    func testExif() {
        let exif = Exif(make: "DJI", model: "FC2103", exposureTime: "1/1000s", aperture: "f/2.8", focalLength: "4.5mm", iso: 100)
        XCTAssertNotNil(exif, "Could not instantiate exif.")
    }
    
    func testDecodePhotos() {
        XCTAssertNotNil(self.decode(modelType: [Photo].self, from: "photos"), "Could not decode photos.")
    }
    
    func testDecodeLike() {
        XCTAssertNotNil(self.decode(modelType: Like.self, from: "like"), "Could not deocde like.")
    }
    
    // MARK: - Statistics
    
    func testDecodeStatistics() {
        XCTAssertNotNil(self.decode(modelType: Statistics.self, from: "statistics"), "Could not decode statistics.")
    }
    
    // MARK: - Searches
    
    func testDecodeSearch() {
        for resource in ["search_photos", "search_collections", "search_users"] {
            XCTAssertNotNil(self.decode(modelType: Search.self, from: resource), "Could not decode search: \(resource)")
        }
    }
    
    // MARK: - Collections
    
    func testDecodeCollection() {
        XCTAssertNotNil(self.decode(modelType: Unsplasher.Collection.self, from: "collection"), "Could not decode collection.")
    }
    
    func testDecodeCollectionList() {
        XCTAssertNotNil(self.decode(modelType: [Unsplasher.Collection].self, from: "collections"), "Could not decode collections.")
    }
    
    // MARK: - OAuth
    
    func testOAuth() {
        let keychain = KeychainWrapper(serviceName: "test")
        _ = keychain.removeAllKeys()
        
        let accessToken = AccessToken(token: "token", tokenType: "beared", scope: "all")
        accessToken.save(in: keychain)
        
        XCTAssertEqual(accessToken, AccessToken.load(from: keychain))
        
        AccessToken.remove(from: keychain)
        XCTAssertNil(AccessToken.load(from: keychain), "Access token could not be removed.")
    }
    
}
