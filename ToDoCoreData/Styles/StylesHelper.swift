//
//  StylesHelper.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 15.11.2023.
//

import UIKit

final class StylesHelper {
    
    static func setupAllStyles() {
        setupNavigationBar()
    }
    
    private static func setupNavigationBar() {
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
    
}
