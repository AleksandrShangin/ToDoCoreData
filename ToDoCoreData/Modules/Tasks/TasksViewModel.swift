//
//  TasksViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import Foundation
import Combine

class TasksViewModel {
    
    let category: Category
    
    let tasks = CurrentValueSubject<[Organizer], Never>([Organizer]())
    
    init(category: Category) {
        self.category = category
    }
    
    func fetchAllTasks() {
        PersistenceServiceImpl.shared.fetchProjectsAndTasks(for: category) { [weak self] tasks in
            self?.tasks.send(tasks)
            for task in tasks {
                print("Project: \(task.project)")
                for task in task.tasks {
                    print(task.name!, task.isCompleted, task.index, task.id)
                }
            }
        }
    }
    // MARK: - Project Methods
    
    func createNewProject(name: String) {
        PersistenceServiceImpl.shared.createNewProject(category: category, name: name) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func updateProject(project: Project, newName: String) {
        PersistenceServiceImpl.shared.updateProject(
            project: project,
            newName: newName
        ) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func deleteProject(project: Project) {
        PersistenceServiceImpl.shared.deleteProject(project: project) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    // MARK: - Task Methods
    
    func createNewTask(project: Project, name: String) {
        PersistenceServiceImpl.shared.createNewTask(
            category: category,
            project: project,
            name: name
        ) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func completeTask(_ task: Task) {
        PersistenceServiceImpl.shared.completeTask(task: task) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func undoCompleteTask(_ task: Task) {
        PersistenceServiceImpl.shared.undoCompleteTask(task: task) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func updateTask(_ task: Task, newName: String) {
        PersistenceServiceImpl.shared.updateTask(task: task, newName: newName) { [weak self] success in
            if success {
                self?.fetchAllTasks()
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        PersistenceServiceImpl.shared.deleteTask(task: task) { [weak self] success in
            if success {
                self?.fetchAllTasks()
                print("Task Deleted")
            }
        }
    }
    
}
