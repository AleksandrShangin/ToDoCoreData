//
//  UIViewController+Extensions.swift
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
        style: UIAlertController.Style,
        actions: [UIAlertAction]
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
            title: "Error",
            message: message,
            style: .alert,
            actions: [
                UIAlertAction(title: "OK", style: .cancel)
            ]
        )
    }
    
    /// Base Ok Alert
    func presentOkAlert(title: String, message: String? = nil, okHandler: @escaping () -> Void) {
        presentAlert(
            title: title,
            message: message,
            style: .alert,
            actions: [
                UIAlertAction(title: "OK", style: .default) { _ in
                    okHandler()
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ]
        )
    }
    
    /// Base Add Alert
    func presentAddAlert(title: String, message: String? = nil, updateName: String?, okHandler: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.autocapitalizationType = .words
            guard let updateName = updateName else {
                return
            }
            textField.text = updateName
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let text = alert.textFields?.last?.text else { return }
            okHandler(text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
