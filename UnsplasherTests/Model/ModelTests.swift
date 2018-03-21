//
//  ModelTests.swift
//  UnsplasherTests
//
//  Created by Adrián Bouza Correa on 21/2/18.
//  Copyright © 2018 adboco. All rights reserved.
//

import XCTest
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
    
    // MARK: - Decode user
    
    func testDecodeUser() {
        XCTAssertNotNil(self.decode(modelType: User.self, from: "user"), "Could not decode user.")
    }
    
    // MARK: - Decode photos
    
    func testDecodePhoto() {
        XCTAssertNotNil(self.decode(modelType: Photo.self, from: "photo"), "Could not decode photo.")
    }
    
    func testDecodePhotos() {
        XCTAssertNotNil(self.decode(modelType: [Photo].self, from: "photos"), "Could not decode photos.")
    }
    
    func testDecodeLike() {
        XCTAssertNotNil(self.decode(modelType: Like.self, from: "like"), "Could not deocde like.")
    }
    
    // MARK: - Decode statistics
    
    func testDecodeStatistics() {
        XCTAssertNotNil(self.decode(modelType: Statistics.self, from: "statistics"), "Could not decode statistics.")
    }
    
    // MARK: - Decode searches
    
    func testDecodeSearch() {
        for resource in ["search_photos", "search_collections", "search_users"] {
            XCTAssertNotNil(self.decode(modelType: Search.self, from: resource), "Could not decode search: \(resource)")
        }
    }
    
    // MARK: - Decode collections
    
    func testDecodeCollection() {
        XCTAssertNotNil(self.decode(modelType: Unsplasher.Collection.self, from: "collection"), "Could not decode collection.")
    }
    
    func testDecodeCollectionList() {
        XCTAssertNotNil(self.decode(modelType: [Unsplasher.Collection].self, from: "collections"), "Could not decode collections.")
    }
    
}
