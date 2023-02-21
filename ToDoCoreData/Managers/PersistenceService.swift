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
    // Generic Combine Methods
    func fetch<T: NSManagedObject>(entity: T.Type) -> AnyPublisher<[T], Error>
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error>
    func delete<T: NSManagedObject>(entity: T) -> AnyPublisher<Void, Error>
    func delete<T: NSManagedObject>(entities: [T]) -> AnyPublisher<Void, Error>
    // Generic Closure Methods
    func insert(object: NSManagedObject, completion: (Result<Void, Error>) -> Void)
    func fetch<T: NSManagedObject>(entity: T.Type, completion: (Result<[T], Error>) -> Void)
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate, completion: (Result<[T], Error>) -> Void)
    func update(entity: NSManagedObject, completion: (Result<Void, Error>) -> Void)
    func delete(entity: NSManagedObject, completion: (Result<Void, Error>) -> Void)
    func delete<T: NSManagedObject>(entity: T, predicate: NSPredicate, completion: (Result<Void, Error>) -> Void)
}
