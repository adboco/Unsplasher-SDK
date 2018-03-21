//
//  Requests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 27/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Result Types

public enum Result<T> {
    case success(T)
    case failure(Error)
    
    /// Returns the value if self represents a success, nil otherwise
    public var value: T? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    /// Returns the error if self represents a failure, nil otherwise
    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}

/// Type alias for access token completion
public typealias AccessTokenResult = Result<AccessToken>

/// Type alias for authorization completion
typealias AuthorizationResult = Result<String>

/// Type alias for authentication completion
public typealias AuthenticationResult = Result<Void>

/// Type alias for user completion
public typealias UserResult = Result<User>

/// Type alias for photo list completion
public typealias PhotoListResult = Result<[Photo]>

/// Type alias for photo completion
public typealias PhotoResult = Result<Photo>

/// Type alias for like completion
public typealias LikeResult = Result<Like>

/// Type alias for collection list completion
public typealias CollectionListResult = Result<[Collection]>

/// Type alias for collection completion
public typealias CollectionResult = Result<Collection>

/// Type alias for collection add or remove photo completion
public typealias CollectionPhotoResult = Result<CollectionPhotoUpdate>

/// Type alias for statistics completion
public typealias StatisticsResult = Result<Statistics>

/// Type alias for search completion
public typealias SearchResult = Result<Search>

/// Type alias for link completion
public typealias LinkResult = Result<Link>

// MARK: - Request parameters

public extension Unsplash {
    
    // MARK: - URLs
    
    static let baseURLString: String = "https://api.unsplash.com"
    
    static let oauthURLString: String = "https://unsplash.com/oauth"
    
    static let tokenURLString: String = Unsplash.oauthURLString + "/token"
    
    static let usersURLString: String = Unsplash.baseURLString + "/users"
    
    static let photosURLString: String = Unsplash.baseURLString + "/photos"
    
    static let searchURLString: String = Unsplash.baseURLString + "/search"
    
    static let collectionsURLString: String = Unsplash.baseURLString + "/collections"
    
    // MARK: - Headers
    
    /// Authorization Header value
    func headers(authenticationNeeded: Bool) -> HTTPHeaders {
        let authorization = authenticationNeeded ? "Bearer " + (self.accessToken?.token ?? "") : "Client-ID " + (applicationID ?? "")
        return [
            "Authorization": authorization,
            "Accept-Version": Unsplash.currentVersion,
            "Content-Type": "application/json"
        ]
    }
    
}

// MARK: - Requests

extension Unsplash {
    
    /// Get link info returned in http response
    ///
    /// - Parameter text: Text
    private func retrieveLinks(from text: String) {
        let links = "(?<=\\<)(.*?)(?=\\>)".matches(in: text)
        let keys = "(?<=rel=\")(.*?)(?=\\\")".matches(in: text)
        for index in 0..<links.count {
            switch keys[index] {
            case "first":
                pagination.first = URL(string: links[index])
            case "last":
                pagination.last = URL(string: links[index])
            case "next":
                pagination.next = URL(string: links[index])
            case "prev":
                pagination.prev = URL(string: links[index])
            default:
                break
            }
        }
    }
    
    /// Method to make request for any type of result model
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - parameters: Parameters
    ///   - needsAuth: Authorization needed
    ///   - expectedType: Result model
    ///   - completion: Completion handler
    func request<T: Codable>(url: String, method: HTTPMethod = .get, parameters: Parameters = [:], includeHeaders: Bool = true, expectedType: T.Type, completion: @escaping (Result<T>) -> Void) {
        guard self.applicationID != nil, self.secret != nil else {
            completion(.failure(UnsplashError.credentialsError))
            return
        }
        if let remaining = self.rateLimitRemaining, let limit = self.rateLimit, remaining <= 0 {
            completion(.failure(UnsplashError.rateLimitError(limit)))
            return
        }
        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.queryString, headers: includeHeaders ? headers(authenticationNeeded: isAuthenticated) : nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                if let rateString = response.response?.allHeaderFields["x-ratelimit-limit"] as? String,
                    let rateRemainingString = response.response?.allHeaderFields["x-ratelimit-remaining"] as? String {
                    self.rateLimit = UInt32(rateString)
                    self.rateLimitRemaining = UInt32(rateRemainingString)
                }
                if let linkString = response.response?.allHeaderFields["Link"] as? String {
                    self.retrieveLinks(from: linkString)
                }
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode {
                        var data: Data
                        switch statusCode {
                        case 204:
                            data = "{\"code\": \(statusCode)}".data(using: .utf8)!
                        default:
                            data = response.data!
                        }
                        guard let result = try? self.decoder.decode(expectedType, from: data) else {
                            completion(.failure(UnsplashError.decodeError))
                            return
                        }
                        completion(.success(result))
                    }
                case .failure(let error):
                    if let data = response.data, let responseError = try? self.decoder.decode(ResponseError.self, from: data) {
                        completion(.failure(UnsplashError.requestError(responseError.error.description)))
                        return
                    }
                    completion(.failure(UnsplashError.requestError(error.localizedDescription)))
                }
        }
    }
    
    // MARK: - Access Token
    
    /// Request an access token for a user
    ///
    /// - Parameters:
    ///   - code: Authorization code
    ///   - completion: Completion handler
    func requestAccessToken(with code: String, completion: @escaping (AccessTokenResult) -> Void) {
        var parameters: Parameters = [:]
        parameters["code"] = code
        parameters["grant_type"] = "authorization_code"
        if let appId = self.applicationID {
            parameters["client_id"] = appId
        }
        if let clientSecret = secret {
            parameters["client_secret"] = clientSecret
        }
        if let redirectURL = self.redirectURLString {
            parameters["redirect_uri"] = redirectURL
        }
        self.request(url: Unsplash.tokenURLString, method: .post, parameters: parameters, includeHeaders: false, expectedType: AccessToken.self) { result in
            switch result {
            case .success(let token):
                self.accessToken = token
                // Save in keychain
                self.accessToken?.save(in: self.keychain)
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Pagination related requests
    
    /// Get first page results
    ///
    /// - Parameter completion: Completion handler
    func first<T: Codable>(_ type: T.Type, completion: @escaping (Result<T>) -> Void) {
        guard let url = pagination.first?.absoluteString else {
            completion(.failure(UnsplashError.noPaginationError("No first page available.")))
            return
        }
        self.request(url: url, expectedType: type, completion: completion)
    }
    
    /// Get last page results
    ///
    /// - Parameter completion: Completion handler
    func last<T: Codable>(_ type: T.Type, completion: @escaping (Result<T>) -> Void) {
        guard let url = pagination.last?.absoluteString else {
            completion(.failure(UnsplashError.noPaginationError("No last page available.")))
            return
        }
        self.request(url: url, expectedType: type, completion: completion)
    }
    
    /// Get next page results
    ///
    /// - Parameter completion: Completion handler
    func next<T: Codable>(_ type: T.Type, completion: @escaping (Result<T>) -> Void) {
        guard let url = pagination.next?.absoluteString else {
            completion(.failure(UnsplashError.noPaginationError("No next page available.")))
            return
        }
        self.request(url: url, expectedType: type, completion: completion)
    }
    
    /// Get previous page results
    ///
    /// - Parameter completion: Completion handler
    func prev<T: Codable>(_ type: T.Type, completion: @escaping (Result<T>) -> Void) {
        guard let url = pagination.prev?.absoluteString else {
            completion(.failure(UnsplashError.noPaginationError("No previous page available.")))
            return
        }
        self.request(url: url, expectedType: type, completion: completion)
    }
    
    // MARK: - Search
    
    /// Search photos, collections and users by terms
    ///
    /// - Parameters:
    ///   - type: Search type
    ///   - query: Search terms
    ///   - page: Page
    ///   - perPage: Number of items per page
    ///   - collections: Collection ID(‘s) to narrow search. If multiple, comma-separated
    ///   - orientation: Orientation
    ///   - completion: Completion handler
    func search(of type: SearchType, query: String, page: UInt32? = nil, perPage: UInt32? = nil, collections: [String]? = nil, orientation: Orientation? = nil, completion: @escaping (SearchResult) -> Void) {
        var parameters: Parameters = [:]
        parameters["query"] = query
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        if let collections = collections {
            parameters["collections"] = collections.joined(separator: ",")
        }
        if let orientation = orientation {
            parameters["orientation"] = orientation.rawValue
        }
        let url = Unsplash.searchURLString + "/" + type.rawValue
        self.request(url: url, parameters: parameters, expectedType: Search.self, completion: completion)
    }
    
}

// MARK: - Pagination

public extension Unsplash {
    
    /// Pagination status
    public struct Pagination {
        
        /// Number of elements returned on each page
        public var perPage: UInt32 = 0
        
        /// Total number of elements
        public var total: UInt32 = 0
        
        /// URL to first page
        public var first: URL?
        
        /// URL to last page
        public var last: URL?
        
        /// URL to next page
        public var next: URL?
        
        /// URL to last page
        public var prev: URL?
        
    }
    
}

// MARK: - Paginable protocol

protocol Paginable {
    
    associatedtype paginableType: Codable
    
    func first(completion: @escaping (Result<paginableType>) -> Void)
    
    func last(completion: @escaping (Result<paginableType>) -> Void)
    
    func next(completion: @escaping (Result<paginableType>) -> Void)
    
    func prev(completion: @escaping (Result<paginableType>) -> Void)
    
}

extension Paginable {
    
    public func first(completion: @escaping (Result<paginableType>) -> Void) {
        Unsplash.shared.first(paginableType.self, completion: completion)
    }
    
    public func last(completion: @escaping (Result<paginableType>) -> Void) {
        Unsplash.shared.last(paginableType.self, completion: completion)
    }
    
    public func next(completion: @escaping (Result<paginableType>) -> Void) {
        Unsplash.shared.next(paginableType.self, completion: completion)
    }
    
    public func prev(completion: @escaping (Result<paginableType>) -> Void) {
        Unsplash.shared.prev(paginableType.self, completion: completion)
    }
    
}
