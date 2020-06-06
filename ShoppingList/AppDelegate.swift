//
//  AppDelegate.swift
//  ShoppingList
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if let _ = Auth.auth().currentUser {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController")
            let nc = window?.rootViewController as? UINavigationController
            nc?.viewControllers = [vc]
        }
        
        return true
    }

}

