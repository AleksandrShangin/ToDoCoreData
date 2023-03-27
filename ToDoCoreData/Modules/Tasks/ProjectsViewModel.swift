//
//  ProjectsViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import Foundation
import Combine

protocol ProjectsViewModelProtocol {
    var projects: CurrentValueSubject<[Organizer], Never> { get }
    var onError: PassthroughSubject<Error, Never> { get }
    
    func fetchProjectsAndTasks()
    
    func createNewProject(name: String)
    func updateProject(project: Project, newName: String)
    func deleteProject(project: Project)
    
    func createNewTask(project: Project, name: String)
    func completeTask(_ task: Task)
    func undoCompleteTask(_ task: Task)
    func renameTask(_ task: Task, with newName: String)
    func deleteTask(_ task: Task)
}

final class ProjectsViewModel: ProjectsViewModelProtocol {
    
    //MARK: - Public Properties
    
    let category: Category
    let projects = CurrentValueSubject<[Organizer], Never>([Organizer]())
    var onError = PassthroughSubject<Error, Never>()
    
    //MARK: - Private Properties
    
    private let persistenceService: PersistenceService
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Init
    
    init(category: Category, persistenceService: PersistenceService = PersistenceServiceImpl.shared) {
        self.category = category
        self.persistenceService = persistenceService
    }
    
    // MARK: - Project Methods
    
    func fetchProjectsAndTasks() {
        var projectTasks: [Organizer] = []
        
        guard let categoryName = category.name else { return }
        let predicate = NSPredicate(format: "category.name = %@", categoryName)
        persistenceService.fetch(entity: Project.self, predicate: predicate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let projects):
                for project in projects {
                    let predicate = NSPredicate(format: "project.name = %@", project.name!)
                    persistenceService.fetch(entity: Task.self, predicate: predicate) { result in
                        switch result {
                        case .success(let tasks):
                            projectTasks.append(Organizer(project: project, tasks: tasks))
                        case .failure(let error):
                            self.onError.send(error)
                        }
                    }
                }
                self.projects.send(projectTasks)
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func createNewProject(name: String) {
        let newProject = Project(context: persistenceService.context)
        newProject.category = self.category
        newProject.name = name
        
        persistenceService.insert(object: newProject) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func updateProject(project: Project, newName: String) {
        project.name = newName
        persistenceService.update(entity: project) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func deleteProject(project: Project) {
        persistenceService.delete(entity: project) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    // MARK: - Task Methods
    
    func createNewTask(project: Project, name: String) {
        let newTask = Task(context: persistenceService.context)
        newTask.category = self.category
        newTask.project = project
        newTask.name = name
        newTask.isCompleted = false
        
        persistenceService.insert(object: newTask) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func completeTask(_ task: Task) {
        task.isCompleted = true
        persistenceService.update(entity: task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func undoCompleteTask(_ task: Task) {
        task.isCompleted = false
        persistenceService.update(entity: task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func renameTask(_ task: Task, with newName: String) {
        task.name = newName
        persistenceService.update(entity: task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        persistenceService.delete(entity: task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
}
