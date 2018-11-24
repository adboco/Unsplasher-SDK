//
//  CurrentUserRequests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 28/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

final public class CurrentUserRequests {
    
    private var manager: Unsplash
    
    private var user: User? {
        didSet {
            photos.user = user
            collections.user = user
        }
    }
    
    /// Photo related requests
    public var photos: CurrentUserPhotosRequests!
    
    /// Collection related requests
    public var collections: CurrentUserCollectionsRequests!
    
    init(_ manager: Unsplash) {
        self.manager = manager
        self.photos = CurrentUserPhotosRequests(manager)
        self.collections = CurrentUserCollectionsRequests(manager)
    }
    
    /// Get current user's profile
    ///
    /// - Parameter completion: Completion handler
    public func profile(completion: @escaping (UserResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .readUser
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let url = Unsplash.baseURLString + "/me"
        self.manager.request(url: url, expectedType: User.self) { result in
            self.user = result.value
            completion(result)
        }
    }
    
    /// Update current user's profile
    ///
    /// - Parameters:
    ///   - user: Current user with modifications
    ///   - completion: Completion handler
    public func update(_ user: User, completion: @escaping (UserResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeUser
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        var parameters: Parameters = [:]
        parameters["username"] = user.username
        if let firstName = user.firstName {
            parameters["first_name"] = firstName
        }
        if let lastName = user.lastName {
            parameters["last_name"] = lastName
        }
        if let email = user.email {
            parameters["email"] = email
        }
        if let url = user.portfolioURL {
            parameters["url"] = url
        }
        if let location = user.location {
            parameters["location"] = location
        }
        if let bio = user.bio {
            parameters["bio"] = bio
        }
        if let instagramAccount = user.instagramUsername {
            parameters["instagram_username"] = instagramAccount
        }
        let url = Unsplash.baseURLString + "/me"
        self.manager.request(url: url, method: .put, parameters: parameters, expectedType: User.self, completion: completion)
    }
    
}

public class CurrentUserPhotosRequests: Paginable {
    
    internal var user: User?
    
    private var userPhotos: UserPhotosRequests!
    
    init(_ manager: Unsplash) {
        self.userPhotos = UserPhotosRequests(manager)
    }
    
    public typealias paginableType = [Photo]
    
    /// Get user photos
    ///
    /// - Parameters:
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - orderBy: Order
    ///   - stats: Show the stats for each user’s photo
    ///   - resolution: The frequency of the stats
    ///   - quantity: The amount of for each stat
    ///   - completion: Completion handler
    public func get(page: Int? = nil, perPage: Int? = nil, orderBy: Unsplash.OrderBy? = .popular, stats: Bool? = false, resolution: Unsplash.StatisticsResolution? = nil, quantity: UInt32 = 30, completion: @escaping (PhotoListResult) -> Void) {
        guard let username = user?.username else {
            completion(.failure(UnsplashError.userProfileNeeded))
            return
        }
        self.userPhotos.by(username, page: page, perPage: perPage, orderBy: orderBy, stats: stats, resolution: resolution, quantity: quantity, completion: completion)
    }
    
    /// Get photos liked by the user
    ///
    /// - Parameters:
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - orderBy: Order
    ///   - completion: Completion handler
    public func liked(page: Int?, perPage: Int?, orderBy: Unsplash.OrderBy?, completion: @escaping (PhotoListResult) -> Void) {
        guard let username = user?.username else {
            completion(.failure(UnsplashError.userProfileNeeded))
            return
        }
        self.userPhotos.liked(by: username, page: page, perPage: perPage, orderBy: orderBy, completion: completion)
    }
    
}

public class CurrentUserCollectionsRequests: Paginable {
    
    internal var user: User?
    
    private var userCollections: UserCollectionsRequests!
    
    init(_ manager: Unsplash) {
        self.userCollections = UserCollectionsRequests(manager)
    }
    
    public typealias paginableType = [Collection]
    
    /// Get list of collections created by the user
    ///
    /// - Parameters:
    ///   - page: Page
    ///   - perPage: Number of collections per page
    ///   - completion: Completion handler
    public func get(page: Int?, perPage: Int?, completion: @escaping (CollectionListResult) -> Void) {
        guard let username = user?.username else {
            completion(.failure(UnsplashError.userProfileNeeded))
            return
        }
        self.userCollections.by(username, page: page, perPage: perPage, completion: completion)
    }
    
}
