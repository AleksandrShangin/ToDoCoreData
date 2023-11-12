//
//  UIViewController+Alert.swift
//  ToDoCoreData
//
//  Created by Alex on 11/21/21.
//

import UIKit

extension UIViewController {
    
    /// Base Alert
    func presentAlert(
        title: String? = nil,
        message: String? = nil,
        actions: [UIAlertAction],
        style: UIAlertController.Style = .alert
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: style
        )
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
    
    /// Base Error Alert
    func presentErrorAlert(message: String) {
        presentAlert(
            title: L10n.Common.error,
            message: message,
            actions: [
                UIAlertAction(title: L10n.Common.ok, style: .cancel)
            ]
        )
    }
    
    /// Base Ok Alert
    func presentOkAlert(
        title: String,
        message: String? = nil,
        okHandler: @escaping VoidClosure
    ) {
        presentAlert(
            title: title,
            message: message,
            actions: [
                UIAlertAction(title: L10n.Common.ok, style: .default) { _ in
                    okHandler()
                },
                UIAlertAction(title: L10n.Common.cancel, style: .cancel)
            ]
        )
    }
    
    /// Base Add Alert
    func presentAddAlert(
        title: String,
        message: String? = nil,
        updateName: String? = nil,
        okHandler: @escaping ParameterClosure<String>
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.spellCheckingType = .yes
            
            guard let updateName = updateName else {
                return
            }
            textField.text = updateName
        }
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default) { _ in
            guard let text = alert.textFields?.last?.text else { return }
            okHandler(text)
        })
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        
        present(alert, animated: true)
    }
    
}
