//
//  Task+CoreDataProperties.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 04.05.2023.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var index: Int64
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String
    @NSManaged public var category: Category?
    @NSManaged public var project: Project?

}

extension Task : Identifiable {

}
