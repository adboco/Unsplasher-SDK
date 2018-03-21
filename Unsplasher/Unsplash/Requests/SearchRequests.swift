//
//  SearchRequests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 27/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

final public class SearchRequests: Paginable {
    
    private var manager: Unsplash
    
    init(_ manager: Unsplash) {
        self.manager = manager
    }
    
    typealias paginableType = Search
    
    // MARK: - Users
    
    /// Search users
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - page: Page
    ///   - perPage: Number of users per page
    ///   - collections: Collection ID(‘s) to narrow search. If multiple, comma-separated
    ///   - orientation: Orientation
    ///   - completion: Completion handler
    public func users(query: String, page: UInt32? = nil, perPage: UInt32? = nil, completion: @escaping (SearchResult) -> Void) {
        self.manager.search(of: .users, query: query, page: page, perPage: perPage, completion: completion)
    }
    
    // MARK: - Photos
    
    /// Search photos
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - collections: Collection ID(‘s) to narrow search. If multiple, comma-separated
    ///   - orientation: Orientation
    ///   - completion: Completion handler
    public func photos(query: String, page: UInt32? = nil, perPage: UInt32? = nil, collections: [String]? = nil, orientation: Unsplash.Orientation? = nil, completion: @escaping (SearchResult) -> Void) {
        self.manager.search(of: .photos, query: query, page: page, perPage: perPage, collections: collections, orientation: orientation, completion: completion)
    }
    
    // MARK: - Collections
    
    /// Search collections
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - page: Page
    ///   - perPage: Number of collections per page
    ///   - collections: Collection ID(‘s) to narrow search. If multiple, comma-separated
    ///   - orientation: Orientation
    ///   - completion: Completion handler
    public func collections(query: String, page: UInt32? = nil, perPage: UInt32? = nil, completion: @escaping (SearchResult) -> Void) {
        self.manager.search(of: .collections, query: query, page: page, perPage: perPage, completion: completion)
    }
    
}
