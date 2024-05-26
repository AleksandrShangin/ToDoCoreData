//
//  AlertActionModel.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 25.05.2024.
//

import UIKit

struct AlertActionModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: ParameterClosure<[AlertFieldModel]?>?
    
    init(
        title: String,
        style: UIAlertAction.Style = .default,
        handler: ParameterClosure<[AlertFieldModel]?>? = nil
    ) {
        self.title = title
        if title == L10n.Common.cancel {
            self.style = .cancel
        } else {
            self.style = style
        }
        self.handler = handler
    }
}
