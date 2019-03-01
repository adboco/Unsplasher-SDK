//
//  RequestsTests.swift
//  UnsplasherTests
//
//  Created by Adrian Bouza on 01/03/2019.
//  Copyright © 2019 adboco. All rights reserved.
//

import XCTest
@testable import Unsplasher

class RequestsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let scopes = Unsplash.PermissionScope.allCases.filter({ $0 != .basic })
        Unsplash.configure(appId: TestConstants.Requests.appId, secret: TestConstants.Requests.secret, scopes: scopes)
        let accessToken = AccessToken(
            token: TestConstants.Requests.token,
            tokenType: "bearer",
            scope: Unsplash.shared.scopes.map({ $0.rawValue }).joined(separator: " "))
        Unsplash.shared.accessToken = accessToken
    }
    
    override func tearDown() {
        super.tearDown()
    }

}

extension Result {
    
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
