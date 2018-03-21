//
//  CollectionRequests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 27/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

final public class CollectionRequests: Paginable {
    
    private var manager: Unsplash
    
    init(_ manager: Unsplash) {
        self.manager = manager
    }
    
    typealias paginableType = [Collection]
    
    /// Get a single page from the list of all collections
    ///
    /// - Parameters:
    ///   - list: Collections from list: curated, featured, any.
    ///   - page: Page
    ///   - perPage: Number of collections per page
    ///   - completion: Completion handler
    public func collections(list: Unsplash.CollectionListType = .any, page: Int? = nil, perPage: Int? = nil, completion: @escaping (CollectionListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        var url = Unsplash.collectionsURLString
        if list != .any {
            url = url + "/\(list.rawValue)"
        }
        self.manager.request(url: url, parameters: parameters, expectedType: [Collection].self, completion: completion)
    }
    
    /// Get a collection by id
    ///
    /// - Parameters:
    ///   - id: Identifier
    ///   - curated: From curated list
    ///   - completion: Completion handler
    public func collection(id: UInt32, curated: Bool = false, completion: @escaping (CollectionResult) -> Void) {
        let url = Unsplash.collectionsURLString + (curated ? "/curated/\(id)" : "/\(id)")
        self.manager.request(url: url, expectedType: Collection.self, completion: completion)
    }
    
    /// Get collection's photos
    ///
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - completion: Completion hanlder
    public func photos(in collectionId: UInt32, curated: Bool = false, page: Int? = nil, perPage: Int? = nil, completion: @escaping (PhotoListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        let url = Unsplash.collectionsURLString + (curated ? "/curated/\(collectionId)" : "/\(collectionId)") + "/photos"
        self.manager.request(url: url, expectedType: [Photo].self, completion: completion)
    }
    
    /// Get a list of collections related with a given one
    ///
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - completion: Completion handler
    public func collections(relatedWith collectionId: UInt32, completion: @escaping (CollectionListResult) -> Void) {
        let url = Unsplash.collectionsURLString + "/\(collectionId)" + "/related"
        self.manager.request(url: url, expectedType: [Collection].self, completion: completion)
    }
    
    /// Create a new collection
    ///
    /// - Parameters:
    ///   - title: Title
    ///   - description: Description
    ///   - isPrivate: Whether to make this collection private
    ///   - completion: Completion handler
    public func create(title: String, description: String? = nil, isPrivate: Bool? = false, completion: @escaping (CollectionResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeCollections
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        var parameters: Parameters = [:]
        parameters["title"] = title
        if let description = description {
            parameters["description"] = description
        }
        if let isPrivate = isPrivate {
            parameters["private"] = isPrivate
        }
        let url = Unsplash.collectionsURLString
        self.manager.request(url: url, method: .post, parameters: parameters, expectedType: Collection.self, completion: completion)
    }
    
    /// Updated a collection
    ///
    /// - Parameters:
    ///   - id: Collection ID
    ///   - title: Title
    ///   - description: Description
    ///   - isPrivate: Whether to make this collection private
    ///   - completion: Completion handler
    public func update(_ collection: Collection, completion: @escaping (CollectionResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeCollections
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        var parameters: Parameters = [:]
        parameters["title"] = collection.title
        if let description = collection.description {
            parameters["description"] = description
        }
        if let isPrivate = collection.isPrivate {
            parameters["private"] = isPrivate
        }
        let url = Unsplash.collectionsURLString + "/\(collection.id)"
        self.manager.request(url: url, method: .put, parameters: parameters, expectedType: Collection.self, completion: completion)
    }
    
    /// Delete a collection
    ///
    /// - Parameters:
    ///   - id: Collection ID
    ///   - completion: Completion handler
    public func delete(id: UInt32, completion: @escaping (Result<StatusCode>) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeCollections
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let url = Unsplash.collectionsURLString + "/\(id)"
        self.manager.request(url: url, method: .delete, expectedType: StatusCode.self, completion: completion)
    }
    
    /// Add a photo to a collection
    ///
    /// - Parameters:
    ///   - photoId: Photo ID
    ///   - collectionId: Collection ID
    ///   - completion: Completion handler
    public func add(photoId: String, to collectionId: UInt32, completion: @escaping (CollectionPhotoResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeCollections
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let parameters: Parameters = ["photo_id": photoId]
        let url = Unsplash.collectionsURLString + "/\(collectionId)" + "/add"
        self.manager.request(url: url, method: .post, parameters: parameters, expectedType: CollectionPhotoUpdate.self, completion: completion)
    }
    
    /// Remove a photo from a collection
    ///
    /// - Parameters:
    ///   - photoId: Photo ID
    ///   - collectionId: Collection ID
    ///   - completion: Completion handler
    public func remove(photoId: String, from collectionId: UInt32, completion: @escaping (CollectionPhotoResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeCollections
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let parameters: Parameters = ["photo_id": photoId]
        let url = Unsplash.collectionsURLString + "/\(collectionId)" + "/remove"
        self.manager.request(url: url, method: .delete, parameters: parameters, expectedType: CollectionPhotoUpdate.self, completion: completion)
    }
    
}
