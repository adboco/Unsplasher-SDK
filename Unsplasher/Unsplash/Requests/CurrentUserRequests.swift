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
    
    init(_ manager: Unsplash) {
        self.manager = manager
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
        self.manager.request(url: url, expectedType: User.self, completion: completion)
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
