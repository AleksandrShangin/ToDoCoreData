//
//  AlertFactory.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 25.05.2024.
//

import UIKit

class AlertFactory {
    
    private static func createAlert(with model: AlertModel) -> UIAlertController {
        var fieldModels: [AlertFieldModel]?
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: model.style
        )
        
        if model.style != .actionSheet {
            if let alertFields = model.textFields {
                fieldModels = alertFields
                alertFields.enumerated().forEach { alertField in
                    alert.addTextField {
                        $0.tag = alertField.offset
                        $0.placeholder = alertField.element.placeholder
                        $0.text = alertField.element.initialText
                        $0.autocapitalizationType = .words
                        $0.spellCheckingType = .yes
                    }
                }
            }
        }
        
        model.actions.forEach { action in
            alert.addAction(
                UIAlertAction(
                    title: action.title,
                    style: action.style,
                    handler: { _ in
                        if let textFields = alert.textFields {
                            let alertFieldModels = textFields.compactMap { textField in
                                fieldModels?[textField.tag].clone(with: textField.text ?? "")
                            }
                            action.handler?(alertFieldModels)
                        } else {
                            action.handler?(nil)
                        }
                    }
                )
            )
        }
        
        return alert
    }
    
    static func createInfoAlert(
        title: String,
        message: String? = nil,
        okHandler: @escaping VoidClosure
    ) -> UIAlertController {
        let alertModel = AlertModel(
            title: title,
            message: message,
            style: .alert,
            textFields: nil,
            actions: [
                AlertActionModel(
                    title: L10n.Common.ok,
                    style: .default,
                    handler: { _ in
                        okHandler()
                    }
                ),
                AlertActionModel(
                    title: L10n.Common.cancel,
                    style: .cancel,
                    handler: nil
                )
            ]
        )
        
        return createAlert(with: alertModel)
    }
    
    static func createErrorAlert(message: String) -> UIAlertController {
        let alertModel = AlertModel(
            title: L10n.Common.error,
            message: message,
            style: .alert,
            textFields: nil,
            actions: [
                AlertActionModel(
                    title: L10n.Common.ok,
                    style: .cancel,
                    handler: nil
                )
            ]
        )
        
        return createAlert(with: alertModel)
    }
    
    static func createFieldAlert(
        title: String,
        message: String?,
        textFields: [AlertFieldModel],
        actions: [AlertActionModel]
    ) -> UIAlertController {
        
        let model = AlertModel(
            title: title,
            message: message,
            style: .alert,
            textFields: textFields,
            actions: actions
        )
        
        return createAlert(with: model)
    }
    
    static func createBottomSheet(actions: [AlertActionModel]) -> UIAlertController {
        let model = AlertModel(
            title: nil,
            message: nil, 
            style: .actionSheet, 
            textFields: nil,
            actions: actions
        )
        
        return createAlert(with: model)
    }
    
    
}
