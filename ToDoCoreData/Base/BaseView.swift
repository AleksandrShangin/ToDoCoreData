//
//  BaseView.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 29.12.2024.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {}
    
    func setupConstraints() {}
}
