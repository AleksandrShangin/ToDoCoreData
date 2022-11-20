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
    func updateTask(_ task: Task, newName: String)
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
        persistenceService.createNewProject(category: category, name: name) { [weak self] result in
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
        persistenceService.updateEntity(entity: project) { [weak self] result in
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
        let predicate = NSPredicate(format: "project.name = %@", project.name!)
        persistenceService.fetch(entity: Task.self, predicate: predicate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let tasks):
                Publishers.Zip(
                    self.persistenceService.delete(entity: project),
                    self.persistenceService.delete(entities: tasks)
                )
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Deletion finished")
                    case .failure(let error):
                        self.onError.send(error)
                    }
                } receiveValue: { _ in
                    self.fetchProjectsAndTasks()
                }
                .store(in: &subscriptions)
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    // MARK: - Task Methods
    
    func createNewTask(project: Project, name: String) {
        persistenceService.createNewTask(
            category: category,
            project: project,
            name: name
        ) { [weak self] success in
            if success {
                self?.fetchProjectsAndTasks()
            }
        }
    }
    
    func completeTask(_ task: Task) {
        task.isCompleted = true
        persistenceService.updateEntity(entity: task) { [weak self] result in
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
        persistenceService.updateEntity(entity: task) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProjectsAndTasks()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func updateTask(_ task: Task, newName: String) {
        task.name = newName
        persistenceService.updateEntity(entity: task) { [weak self] result in
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
        persistenceService.deleteEntity(entity: task) { [weak self] result in
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
