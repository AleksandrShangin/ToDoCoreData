//
//  UITableViewHeaderFooterView+Extensions.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 02.02.2023.
//

import UIKit

extension UITableViewHeaderFooterView {
    static var reuseId: String {
        return String(describing: self)
    }
}
