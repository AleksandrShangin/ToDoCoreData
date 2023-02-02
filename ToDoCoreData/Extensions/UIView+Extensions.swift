//
//  UIView+Extensions.swift
//  ToDoCoreData
//
//  Created by Alex on 11/24/21.
//

import UIKit

extension UIView {
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var right: CGFloat {
        return left + width
    }
    
    var bottom: CGFloat {
        return top + height
    }
    
}

struct Constants {
    static let mainInsets: CGFloat = 8
}


extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}
