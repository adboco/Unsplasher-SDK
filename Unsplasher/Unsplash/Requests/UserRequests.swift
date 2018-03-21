//
//  UserRequests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 27/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

final public class UserRequests {
    
    private var manager: Unsplash
    
    /// Photo related requests
    public var photos: UserPhotosRequests!
    
    /// Collection related requests
    public var collections: UserCollectionsRequests!
    
    init(_ manager: Unsplash) {
        self.manager = manager
        self.photos = UserPhotosRequests(manager)
        self.collections = UserCollectionsRequests(manager)
    }
    
    /// Get public details on a given user
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - width: Width of profile photo
    ///   - height: Height of profile photo
    ///   - completion: Completion handler
    public func user(_ username: String, width: UInt32? = nil, height: UInt32? = nil, completion: @escaping (UserResult) -> Void) {
        var parameters: Parameters = [:]
        if let width = width {
            parameters["w"] = width
        }
        if let height = height {
            parameters["h"] = height
        }
        let url = Unsplash.usersURLString + "/\(username)"
        self.manager.request(url: url, parameters: parameters, expectedType: User.self, completion: completion)
    }
    
    /// Get user's portfolio link
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - completion: Completion handler
    public func portfolio(by username: String, completion: @escaping (LinkResult) -> Void) {
        let url = Unsplash.usersURLString + "/\(username)" + "/portfolio"
        self.manager.request(url: url, expectedType: Link.self, completion: completion)
    }
    
    // MARK: - Statistics
    
    /// Get user statistics by username
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - resolution: Resolution
    ///   - quantity: Quantity
    ///   - completion: Completion handler
    public func statistics(username: String, resolution: Unsplash.StatisticsResolution? = nil, quantity: UInt32 = 30, completion: @escaping (StatisticsResult) -> Void) {
        var parameters: Parameters = [:]
        if let resolution = resolution {
            parameters["resolution"] = resolution
        }
        if 1...30 ~= quantity {
            parameters["quantity"] = quantity
        } else {
            completion(.failure(UnsplashError.wrongQuantityError))
        }
        let url = Unsplash.usersURLString + "/\(username)" + "/statistics"
        self.manager.request(url: url, parameters: parameters, expectedType: Statistics.self, completion: completion)
    }
    
}

final public class UserPhotosRequests: Paginable {
    
    private var manager: Unsplash
    
    init(_ manager: Unsplash) {
        self.manager = manager
    }
    
    typealias paginableType = [Photo]
    
    /// Get a list of photos uploaded by an user.
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - orderBy: Order
    ///   - stats: Show the stats for each user’s photo
    ///   - resolution: The frequency of the stats
    ///   - quantity: The amount of for each stat
    ///   - completion: Completion handler
    public func by(_ username: String, page: Int? = nil, perPage: Int? = nil, orderBy: Unsplash.OrderBy? = .popular, stats: Bool? = false, resolution: Unsplash.StatisticsResolution? = nil, quantity: UInt32 = 30, completion: @escaping (PhotoListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        if let stats = stats {
            parameters["stats"] = stats
        }
        if let orderBy = orderBy {
            parameters["order_by"] = orderBy
        }
        if let resolution = resolution {
            parameters["resolution"] = resolution
        }
        if 1...30 ~= quantity {
            parameters["quantity"] = quantity
        } else {
            completion(.failure(UnsplashError.wrongQuantityError))
        }
        let url = Unsplash.usersURLString + "/\(username)" + "/photos"
        self.manager.request(url: url, parameters: parameters, expectedType: [Photo].self, completion: completion)
    }
    
    /// Get a list of photos liked by a given user
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - orderBy: Order
    ///   - completion: Completion handler
    public func liked(by username: String, page: Int? = nil, perPage: Int? = nil, orderBy: Unsplash.OrderBy? = .popular, completion: @escaping (PhotoListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        if let orderBy = orderBy {
            parameters["order_by"] = orderBy
        }
        let url = Unsplash.usersURLString + "/\(username)" + "/likes"
        self.manager.request(url: url, parameters: parameters, expectedType: [Photo].self, completion: completion)
    }
    
}

final public class UserCollectionsRequests: Paginable {
    
    private var manager: Unsplash
    
    init(_ manager: Unsplash) {
        self.manager = manager
    }
    
    typealias paginableType = [Collection]
    
    /// Get a list of collections created by a given user
    ///
    /// - Parameters:
    ///   - username: Username
    ///   - page: Page
    ///   - perPage: Number of collections per page
    ///   - completion: Completion handler
    public func by(_ username: String, page: Int? = nil, perPage: Int? = nil, completion: @escaping (CollectionListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        let url = Unsplash.usersURLString + "/\(username)" + "/collections"
        self.manager.request(url: url, parameters: parameters, expectedType: [Collection].self, completion: completion)
    }
    
}
