//
//  Unsplash.swift
//  Unsplasher
//
//  Created by Adrian Bouza Correa on 19/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

public final class Unsplash {
    
    // MARK: - Singleton
    
    /// Shared instance
    public static let shared = Unsplash()
    
    private init() {
        self.currentUser = CurrentUserRequests(self)
        self.users = UserRequests(self)
        self.photos = PhotoRequests(self)
        self.collections = CollectionRequests(self)
        self.search = SearchRequests(self)
    }
    
    // MARK: - Routes
    
    /// Current user related functions
    public var currentUser: CurrentUserRequests!
    
    /// User related functions
    public var users: UserRequests!
    
    /// Photo related functions
    public var photos: PhotoRequests!
    
    /// Collection related functions
    public var collections: CollectionRequests!
    
    /// Search functions
    public var search: SearchRequests!
    
    // MARK: - Config parameters
    
    /// Current API version
    public static let currentVersion: String = "v1"
    
    /// Application ID
    var applicationID: String?
    
    /// Secret
    var secret: String?
    
    /// Access Token
    var accessToken: AccessToken?
    
    /// Indicates if the current user is authenticated
    public var isAuthenticated: Bool {
        guard let token = accessToken else {
            return false
        }
        // Check if the access token includes all requested scopes
        for scope in scopes {
            if !token.scope.contains(scope.rawValue) {
                return false
            }
        }
        return true
    }
    
    /// Redirect url for Unsplash authorization
    var redirectURLString: String? {
        guard let appId = self.applicationID else {
            return nil
        }
        return "unsplash-\(appId)://token"
    }
    
    /// To write data on behalf of a user or to access their private data, you must request additional permission scopes from them
    var scopes: [PermissionScope] = [.basic]
    
    /// Direct users to this URL to get authorization
    public var authorizationURL: URL? {
        guard let redirectURL = self.redirectURLString else {
            return nil
        }
        var components = URLComponents(string: Unsplash.oauthURLString + "/authorize")
        
        let scopesString = scopes.map({ $0.rawValue }).joined(separator: "+")
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: self.applicationID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURL),
            URLQueryItem(name: "scope", value: scopesString)
        ]
        return components?.url
    }
    
    // MARK: - Status
    
    /// Limit of requests per hour
    public var rateLimit: UInt32?
    
    /// Remaining requests per hour
    public var rateLimitRemaining: UInt32?
    
    /// Information about pagination if any
    var pagination = Pagination()
    
    // MARK: - Utils
    
    /// Keychain Wrapper to save access token
    var keychain: KeychainWrapper? {
        guard let appId = self.applicationID else {
            return nil
        }
        return KeychainWrapper(serviceName: appId)
    }
    
    /// JSON decoder for API responses
    let decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        return jsonDecoder
    }()
    
    // MARK: - Initialization
    
    /// Method to setup Unsplash client with app ID and secret
    ///
    /// - Parameters:
    ///   - appId: App ID
    ///   - secret: Secret
    public static func configure(appId: String, secret: String? = nil, scopes: [PermissionScope] = [.basic]) {
        shared.applicationID = appId
        shared.secret = secret
        shared.scopes = scopes
        if !scopes.contains(.basic) {
            shared.scopes.insert(.basic, at: 0)
        }
        
        shared.accessToken = AccessToken.load(from: shared.keychain)
    }
    
}

// MARK: - Enums

public extension Unsplash {
    
    /// Permission scopes
    ///
    /// - basic: Read public data
    /// - readUser: Access user’s private data
    /// - writeUser: Update the user’s profile
    /// - readPhotos: Read private data from the user’s photos
    /// - writePhotos: Update photos on the user’s behalf
    /// - writeLikes: Like or unlike a photo on the user’s behalf
    /// - writeFollowers: Follow or unfollow a user on the user’s behalf
    /// - readCollections: View a user’s private collections
    /// - writeCollections: Create and update a user’s collections
    public enum PermissionScope: String {
        
        case basic = "public"
        case readUser = "read_user"
        case writeUser = "write_user"
        case readPhotos = "read_photos"
        case writePhotos = "write_photos"
        case writeLikes = "write_likes"
        case writeFollowers = "write_followers"
        case readCollections = "read_collections"
        case writeCollections = "write_collections"
        
        public static var all: [PermissionScope] {
            var scopes: [PermissionScope] = []
            scopes.append(.basic)
            scopes.append(.readUser)
            scopes.append(.writeUser)
            scopes.append(.readPhotos)
            scopes.append(.writePhotos)
            scopes.append(.writeLikes)
            scopes.append(.writeFollowers)
            scopes.append(.readCollections)
            scopes.append(.writeCollections)
            return scopes
        }
    }
    
    /// Order by filter
    ///
    /// - latest: Lastest
    /// - oldest: Oldest
    /// - popular: Popular
    public enum OrderBy: String {
        case latest, oldest, popular
    }
    
    /// Orientation
    ///
    /// - landscape: Landscape
    /// - portrait: Portrait
    /// - squarish: Squarish
    public enum Orientation: String {
        case landscape, portrait, squarish
    }
    
    /// Resolution of stats
    ///
    /// - days: Days
    public enum StatisticsResolution: String {
        case days
    }
    
    /// Different types of search
    ///
    /// - photos: Photos
    /// - collections: Collections
    /// - users: Users
    public enum SearchType: String {
        case photos, collections, users
    }
    
    /// Collection list types
    ///
    /// - featured: Featured collections
    /// - curated: Curated collections
    /// - any: All types
    public enum CollectionListType: String {
        case any, featured, curated
        
        static var allValues: [CollectionListType] {
            var all: [CollectionListType] = []
            switch CollectionListType.any {
            case .any: all.append(.any); fallthrough
            case .featured: all.append(.featured); fallthrough
            case .curated: all.append(.curated)
            }
            return all
        }
    }
    
}

// MARK: - Errors

/// Unsplash related errors
///
/// - unknownError: Unknown
/// - decodeError: Error decoding response
/// - requestError: Error requesting resource
/// - rateLimitError: Rate limit exceeded
/// - scopeRequiredError: The request requires a scope that is not allowed
/// - wrongCountError: Wrong count value
/// - wrongQuantityError: Wrong quantity value
/// - noPaginationError: Error getting specific page
/// - authorizationError: Authorization error
/// - authenticationError: Authentication error
/// - cancelAuthenticationError: User cancels authentication process
/// - credentialsError: Credentials not specified
public enum UnsplashError: Error {
    
    case unknownError
    case decodeError
    case requestError(String)
    case rateLimitError(UInt32)
    case scopeRequiredError(Unsplash.PermissionScope)
    case wrongCountError
    case wrongQuantityError
    case noPaginationError(String)
    case authorizationError
    case authenticationError
    case cancelAuthenticationError
    case credentialsError
    
}

extension UnsplashError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .unknownError:
            return "Unknown error."
        case .decodeError:
            return "Error decoding json response."
        case .requestError(let error):
            return "Error in request: \(error)"
        case .rateLimitError(let limit):
            return "You have reached the limit of \(limit) per hour."
        case .scopeRequiredError(let scope):
            return "This request requires \(scope.rawValue) scope."
        case .wrongCountError:
            return "Wrong count value. Must be between 1 and 30."
        case .wrongQuantityError:
            return "Wrong quantity value. Must be between 1 and 30."
        case .noPaginationError(let error):
            return "Error getting page: \(error)"
        case .authorizationError:
            return "Could not get authorization code."
        case .authenticationError:
            return "Error authenticating user."
        case .cancelAuthenticationError:
            return "User has cancelled authentication process."
        case .credentialsError:
            return "Unable to make requests. You must configure credentials first."
        }
    }
    
}

extension UnsplashError: LocalizedError {
    
    public var errorDescription: String? {
        return description
    }
    
    public var localizedDescription: String {
        return description
    }
    
}

// MARK: - Authentication

extension Unsplash {
    
    /// Authenticate the user
    ///
    /// - Parameter completion: Completion handler
    public func authenticate(_ viewController: UIViewController, completion: @escaping (AuthenticationResult) -> Void) {
        guard !self.isAuthenticated else {
            completion(.success(()))
            return
        }
        AuthorizationManager.authorize(from: viewController, url: self.authorizationURL, callbackURLScheme: self.redirectURLString) { result in
            switch result {
            case .success(let code):
                self.requestAccessToken(with: code, completion: { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
}
