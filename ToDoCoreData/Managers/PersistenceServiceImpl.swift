//
//  PersistenceServiceImpl.swift
//  ToDoCoreData
//
//  Created by Alex on 11/5/21.
//

import Foundation
import CoreData

protocol PersistenceService {
    // Categories
    func createCategory(name: String, completion: (Bool) -> Void)
    func fetchAllCategories(completion: (Result<[Category], Error>) -> Void)
    func updateCategory(category: Category, newName: String, completion: (Bool) -> Void)
    func deleteCategory(category: Category, completion: (Bool) -> Void)
    // Projects
    func createNewProject(category: Category, name: String, completion: (Bool) -> Void)
    func fetchProjectsAndTasks(for category: Category, completion: ([Organizer]) -> Void)
    func updateProject(project: Project, newName: String, completion: (Bool) -> Void)
    func deleteProject(project: Project, completion: (Bool) -> Void)
    // Tasks
    func createNewTask(category: Category, project: Project, name: String, completion: (Bool) -> Void)
    func completeTask(task: Task, completion: (Bool) -> Void)
    func deleteTask(task: Task, completion: (Bool) -> Void)
}

final class PersistenceServiceImpl: PersistenceService {
    
    static let shared = PersistenceServiceImpl()
    
    private init() {}
    
    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoCoreData")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data: Changes saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Category Methods
    
    func createCategory(name: String, completion: (Bool) -> Void) {
        let category = Category(context: context)
        category.name = name
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func fetchAllCategories(completion: (Result<[Category], Error>) -> Void) {
        let request = NSFetchRequest<Category>(entityName: "Category")
        do {
            let categories = try context.fetch(request)
            completion(.success(categories))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateCategory(category: Category, newName: String, completion: (Bool) -> Void) {
        category.name = newName
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func deleteCategory(category: Category, completion: (Bool) -> Void) {
        context.delete(category)
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    // MARK: - Projects Methods
    
    func createNewProject(category: Category, name: String, completion: (Bool) -> Void) {
        let newProject = Project(context: context)
        newProject.name = name
        newProject.category = category
        do {
            try context.save()
            print("saved")
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
    }
    
    func fetchProjectsAndTasks(for category: Category, completion: ([Organizer]) -> Void) {
        let request = NSFetchRequest<Project>(entityName: "Project")
        guard let categoryName = category.name else { return }
        let predicate = NSPredicate(format: "category.name = %@", categoryName)
        request.predicate = predicate
        var projectTasks: [Organizer] = []
        do {
            let projects = try context.fetch(request)
            for project in projects {
                let request = NSFetchRequest<Task>(entityName: "Task")
                let predicate = NSPredicate(format: "project.name = %@", project.name!)
                request.predicate = predicate
                do {
                    let tasks = try context.fetch(request)
                    projectTasks.append(Organizer(project: project, tasks: tasks))
                } catch {
                    print(error)
                }
            }
            completion(projectTasks)
        } catch {
            print(error)
        }
    }
    
    func updateProject(project: Project, newName: String, completion: (Bool) -> Void) {
        project.name = newName
        do {
            try context.save()
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
    }
    
    func deleteProject(project: Project, completion: (Bool) -> Void) {
        let request = NSFetchRequest<Task>(entityName: "Task")
        let predicate = NSPredicate(format: "project.name = %@", project.name!)
        request.predicate = predicate
        do {
            let tasks = try context.fetch(request)
            for task in tasks {
                context.delete(task)
            }
            context.delete(project)
            do {
                try context.save()
                print("Project Deleted")
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        } catch {
            print(error)
            completion(false)
        }
    }
    
    // MARK: - Task Methods
    
    func createNewTask(category: Category, project: Project, name: String, completion: (Bool) -> Void) {
        let newTask = Task(context: context)
        newTask.name = name
        newTask.isCompleted = false
        newTask.category = category
        newTask.project = project
        do {
            let tasks = try context.fetch(Task.fetchRequest())
            newTask.index = Int64(tasks.count-1)
        } catch {
            print("Could not fetch Core Data entities: \(error)")
        }
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func completeTask(task: Task, completion: (Bool) -> Void) {
        task.isCompleted = true
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func undoCompleteTask(task: Task, completion: (Bool) -> Void) {
        task.isCompleted = false
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func deleteTask(task: Task, completion: (Bool) -> Void) {
        context.delete(task)
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func updateTask(task: Task, newName: String, completion: (Bool) -> Void) {
        task.name = newName
        do {
            try context.save()
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
    }
    
}
