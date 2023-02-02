//
//  UICollectionView+Extensions.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 02.02.2023.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cell: T.Type) {
        self.register(cell, forCellWithReuseIdentifier: cell.reuseId)
    }
    
    func dequeueCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else {
            fatalError("dequeue Error: \(cellType.reuseId)")
        }
        return cell
    }
}
