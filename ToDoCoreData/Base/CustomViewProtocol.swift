//
//  CustomViewProtocol.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 07.11.2023.
//

import UIKit

protocol CustomViewProtocol {
    associatedtype RootView: UIView
}

extension CustomViewProtocol where Self: UIViewController {
    var customView: RootView { view as! RootView }
}
