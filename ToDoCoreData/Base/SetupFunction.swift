//
//  SetupFunction.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import Foundation

func setup<T>(_ object: T, block: (T) -> Void) -> T {
    block(object)
    return object
}
