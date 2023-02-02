//
//  UITableView+Extensions.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 02.02.2023.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cell: T.Type) {
        self.register(cell, forCellReuseIdentifier: cell.reuseId)
    }
    
    func register<T: UITableViewHeaderFooterView>(view: T.Type) {
        self.register(view, forHeaderFooterViewReuseIdentifier: view.reuseId)
    }
    
    func dequeueCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseId, for: indexPath) as? T else {
            fatalError("dequeue Error: \(cellType.reuseId)")
        }
        return cell
    }
    
    func dequeueView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseId) as? T else {
            fatalError("dequeue Error: \(viewType.reuseId)")
        }
        return view
    }
    
}
