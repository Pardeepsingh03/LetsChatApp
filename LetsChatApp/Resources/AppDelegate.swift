//
//  AppDelegate.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    FirebaseApp.configure()
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
  
    return true
}
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {

        return GIDSignIn.sharedInstance.handle(url)
    }
      
}


