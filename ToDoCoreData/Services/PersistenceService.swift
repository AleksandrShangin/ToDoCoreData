//
//  PersistenceService.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 21.02.2023.
//

import Foundation
import CoreData
import Combine

protocol PersistenceService {
    var context: NSManagedObjectContext { get }
    
    func insert(object: NSManagedObject) -> AnyPublisher<Void, Error>
    func fetch<T: NSManagedObject>(entity: T.Type) -> AnyPublisher<[T], Error>
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error>
    func update(entity: NSManagedObject) -> AnyPublisher<Void, Error>
    func delete<T: NSManagedObject>(entity: T) -> AnyPublisher<Void, Error>
}
