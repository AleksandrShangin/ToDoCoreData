//
//  BaseRouter.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import UIKit

class BaseRouter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
