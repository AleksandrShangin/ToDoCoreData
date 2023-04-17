//
//  ProjectsViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import Foundation
import Combine

protocol ProjectsViewModel {
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

final class ProjectsViewModelImpl: ProjectsViewModel {
    
    //MARK: - Public Properties
    
    let category: Category
    let projects = CurrentValueSubject<[Organizer], Never>([Organizer]())
    var onError = PassthroughSubject<Error, Never>()
    
    //MARK: - Private Properties
    
    private let persistenceService: PersistenceService
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Init
    
    init(category: Category, persistenceService: PersistenceService) {
        self.category = category
        self.persistenceService = persistenceService
    }
    
    // MARK: - Project Methods
    
    func fetchProjectsAndTasks() {
        let predicate = NSPredicate(format: "category.name = %@", category.name)
        
        persistenceService.fetch(entity: Project.self, predicate: predicate)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] projects in
                let projectTasks = projects.map { Organizer(project: $0, tasks: Array($0.tasks)) }
                self?.projects.send(projectTasks)
            })
            .store(in: &subscriptions)
    }
    
    func createNewProject(name: String) {
        let newProject = Project(context: persistenceService.context)
        newProject.category = self.category
        newProject.name = name
        
        persistenceService.insert(object: newProject)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func updateProject(project: Project, newName: String) {
        project.name = newName
        
        persistenceService.update(entity: project)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: {
                [weak self] in
                    self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func deleteProject(project: Project) {
        persistenceService.delete(entity: project)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Task Methods
    
    func createNewTask(project: Project, name: String) {
        let newTask = Task(context: persistenceService.context)
        newTask.category = self.category
        newTask.project = project
        newTask.name = name
        newTask.isCompleted = false
        
        persistenceService.insert(object: newTask)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func completeTask(_ task: Task) {
        task.isCompleted = true
        
        persistenceService.update(entity: task)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func undoCompleteTask(_ task: Task) {
        task.isCompleted = false
        
        persistenceService.update(entity: task)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func renameTask(_ task: Task, with newName: String) {
        task.name = newName
        
        persistenceService.update(entity: task)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
    func deleteTask(_ task: Task) {
        persistenceService.delete(entity: task)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchProjectsAndTasks()
            })
            .store(in: &subscriptions)
    }
    
}
