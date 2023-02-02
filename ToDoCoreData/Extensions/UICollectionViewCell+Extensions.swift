//
//  UICollectionViewCell+Extensions.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 02.02.2023.
//

import UIKit

extension UICollectionViewCell {
    static var reuseId: String {
        return String(describing: self)
    }
}
