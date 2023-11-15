//
//  AppDelegate.swift
//  ToDoCoreData
//
//  Created by Alex on 10/18/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupWindow()
        setupAppSettings()
        return true
    }
    
    // MARK: - Setup
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let categoriesViewController = CategoriesFactory().build()
        window?.rootViewController = UINavigationController(rootViewController: categoriesViewController)
        window?.makeKeyAndVisible()
    }
    
    private func setupAppSettings() {
        StylesHelper.setupAllStyles()
    }

}

