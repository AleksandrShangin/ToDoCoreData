//
//  SetupFunction.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import Foundation

func setup<Type>(_ object: Type, block: (Type) -> Void) -> Type {
    block(object)
    return object
}
