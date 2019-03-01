//
//  AppDelegate.swift
//  Example
//
//  Created by Adrian Bouza Correa on 20/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit
import Unsplasher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let appId = "YOUR_APPLICATION_ID"
    let secret = "YOUR_SECRET"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup application ID and Secret
        Unsplash.configure(appId: appId, secret: secret, scopes: Unsplash.PermissionScope.allCases)
        
        return true
    }

}

