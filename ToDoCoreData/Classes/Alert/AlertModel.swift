//
//  AlertModel.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 25.05.2024.
//

import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    let style: UIAlertController.Style
    let textFields: [AlertFieldModel]?
    let actions: [AlertActionModel]
}
