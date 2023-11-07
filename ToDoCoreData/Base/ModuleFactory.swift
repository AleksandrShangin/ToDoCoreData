//
//  ModuleFactory.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 27.03.2023.
//

import Foundation

protocol ModuleFactory {
    associatedtype ViewController
    
    func build() -> ViewController
}
