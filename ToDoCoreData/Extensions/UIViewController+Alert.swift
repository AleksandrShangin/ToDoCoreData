//
//  UIViewController+Alert.swift
//  ToDoCoreData
//
//  Created by Alex on 11/21/21.
//

import UIKit

enum AlertType {
    case error(message: String)
    case info(title: String, message: String? = nil, okHandler:  VoidClosure)
    case withField(title: String, message: String? = nil, textField: AlertFieldModel, okHandler: ParameterClosure<AlertFieldModel>)
    case bottomSheet(actions: [AlertActionModel])
}

extension UIViewController {
    
    func presentAlert(type: AlertType) {
        let alert: UIAlertController
        
        switch type {
        case .error(let message):
            alert = AlertFactory.createErrorAlert(message: message)
        case .info(let title, let message, let okHandler):
            alert = AlertFactory.createInfoAlert(title: title, message: message, okHandler: okHandler)
        case .withField(let title, let message, let textField, let okHandler):
            alert = AlertFactory.createFieldAlert(
                title: title,
                message: message,
                textFields: [textField],
                actions: [
                    AlertActionModel(
                        title: L10n.Common.ok,
                        style: .default,
                        handler: { models in
                            if let model = models?.first {
                                okHandler(model)
                            }
                        }
                    ),
                    AlertActionModel(title: L10n.Common.cancel, style: .cancel, handler: nil)
                ]
            )
        case .bottomSheet(let actions):
            alert = AlertFactory.createBottomSheet(actions: actions)
        }
        
        present(alert, animated: true)
    }
    
}
