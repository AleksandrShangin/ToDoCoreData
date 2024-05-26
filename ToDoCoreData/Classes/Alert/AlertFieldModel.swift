//
//  AlertFieldModel.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 25.05.2024.
//

import Foundation

struct AlertFieldModel {
    let type: AlertFieldType
    
    var placeholder: String? {
        switch self.type {
        case .category, .project, .task:
            return nil
        }
    }
    
    let initialText: String?
    var text: String? = ""
    
    func clone(with text: String) -> Self {
        return AlertFieldModel(
            type: type,
            initialText: initialText,
            text: text
        )
    }
}

extension AlertFieldModel {
    init(type: AlertFieldType) {
        self.type = type
        self.initialText = ""
    }
}

enum AlertFieldType {
    case category
    case project
    case task
}
