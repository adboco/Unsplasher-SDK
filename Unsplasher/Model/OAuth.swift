//
//  OAuth.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 23/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

public struct AccessToken: Codable {
    
    public let token: String
    public let tokenType: String
    public let scope: String
    
    private enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
        case scope
    }
    
    func save(in keychain: KeychainWrapper?) {
        guard let keychain = keychain else {
            return
        }
        keychain.set(self.token, forKey: "token")
        keychain.set(self.tokenType, forKey: "token_type")
        keychain.set(self.scope, forKey: "scope")
    }
    
    static func load(from keychain: KeychainWrapper?) -> AccessToken? {
        guard let keychain = keychain else {
            return nil
        }
        guard let token = keychain.string(forKey: "token"),
            let tokenType = keychain.string(forKey: "token_type"),
            let scope = keychain.string(forKey: "scope") else {
            return nil
        }
        return AccessToken(token: token, tokenType: tokenType, scope: scope)
    }
    
}
