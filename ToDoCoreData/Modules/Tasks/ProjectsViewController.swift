//
//  ProjectsViewController.swift
//  ToDoCoreData
//
//  Created by Alex on 4/20/21.
//

import UIKit
import Combine

final class ProjectsViewController: UIViewController, CustomViewProtocol {
    typealias RootView = ProjectsView
    
    // MARK: - Properties
    
    private var dataSource: ProjectsDataSource!
    private let viewModel: ProjectsViewModel
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: ProjectsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        let view = ProjectsView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configureViews()
        configureNavigationBar()
        configureBindings()
    }
    
    // MARK: - Configure
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
    }
    
    private func configureViews() {
        dataSource = ProjectsDataSource(tableView: self.customView.tableView)
        customView.tableView.dataSource = dataSource
        customView.tableView.delegate = self
    }
    
    // MARK: - Overriden Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        customView.tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        viewModel.fetchProjectsAndTasks()
    }
    
    // MARK: - Bindings
    
    private func configureBindings() {
        viewModel.projects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dataSource.items = $0 }
            .store(in: &cancellable)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.presentAlert(type: .error(message: $0.localizedDescription)) }
            .store(in: &cancellable)
        
        viewModel.onTaskUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPath in
                self?.customView.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            .store(in: &cancellable)
        
        viewModel.onProjectUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexSet in
                self?.customView.tableView.reloadSections(indexSet, with: .automatic)
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddButton() {
        self.presentAlert(type: .withField(
            title: L10n.Project.new,
            textField: AlertFieldModel(type: .project),
            okHandler: { [weak self] model in
                guard let self = self, let name = model.text else { return }
                self.viewModel.createNewProject(name: name)
            })
        )
    }
    
    private func didTapMenu(project: Project, indexSet: IndexSet) {
        self.presentAlert(type: .bottomSheet(
            actions: [
                AlertActionModel(
                    title: L10n.Task.new,
                    handler: { [weak self] _ in
                        self?.presentAlert(type: .withField(
                            title: L10n.Task.new,
                            textField: AlertFieldModel(type: .task),
                            okHandler: { model in
                                if let taskName = model.text {
                                    self?.viewModel.createNewTask(project: project, name: taskName)
                                }
                            })
                        )
                    }
                ),
                AlertActionModel(
                    title: L10n.Project.rename,
                    handler: { [weak self] _ in
                        self?.presentAlert(type: .withField(
                            title: L10n.Project.rename,
                            textField: AlertFieldModel(type: .project, initialText: project.name),
                            okHandler: { [weak self] model in
                                if let newName = model.text {
                                    self?.viewModel.updateProject(project: project, newName: newName, indexSet: indexSet)
                                }
                            })
                        )
                    }
                ),
                AlertActionModel(
                    title: L10n.Project.delete,
                    handler: { [weak self] _ in
                        self?.presentAlert(type: .info(
                            title: "\(L10n.Project.delete)?",
                            okHandler: {
                                self?.viewModel.deleteProject(project: project)
                            })
                        )
                    }
                ),
                AlertActionModel(title: L10n.Common.cancel)
            ])
        )
    }
    
    private func didSelectTask(_ selectedTask: Task, indexPath: IndexPath) {
        let undoCompleteAction = AlertActionModel(
            title: L10n.Task.undoComplete,
            handler: { [weak self] _ in
                self?.presentAlert(type: .info(
                    title: "\(L10n.Task.undoComplete)?",
                    okHandler: {
                        self?.viewModel.undoCompleteTask(selectedTask, indexPath: indexPath)
                    })
                )
            }
        )
        
        let completeAction = AlertActionModel(
            title: L10n.Task.complete,
            handler: { [weak self] _ in
                self?.viewModel.completeTask(selectedTask, indexPath: indexPath)
            }
        )
        
        let updateAction = AlertActionModel(
            title: L10n.Task.rename,
            handler: { [weak self] _ in
                self?.presentAlert(type: .withField(
                    title: L10n.Task.rename,
                    textField: AlertFieldModel(type: .category, initialText: selectedTask.name),
                    okHandler: { model in
                        if let newName = model.text {
                            self?.viewModel.renameTask(selectedTask, with: newName, indexPath: indexPath)
                        }
                    })
                )
            }
        )
        
        let deleteAction = AlertActionModel(
            title: L10n.Task.delete,
            style: .destructive,
            handler: { [weak self] _ in
                self?.presentAlert(type: .info(
                    title: "\(L10n.Task.delete)?",
                    message: selectedTask.name,
                    okHandler: {
                        self?.viewModel.deleteTask(selectedTask)
                    })
                )
            }
        )
        
        let cancelAction = AlertActionModel(title: L10n.Common.cancel)
        
        let actions = !selectedTask.isCompleted ? [completeAction, updateAction, deleteAction, cancelAction] : [undoCompleteAction, updateAction, deleteAction, cancelAction]
        
        presentAlert(type: .bottomSheet(actions: actions))
    }

}


// MARK: - Extension For UITableViewDelegate

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueView(ProjectHeaderView.self)
        
        let projectName = viewModel.projects.value[section].project.name
        header.tag = section
        header.configure(with: projectName)
        header.delegate = self
        return header
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = viewModel.projects.value[indexPath.section].tasks[indexPath.row]
        self.didSelectTask(selectedTask, indexPath: indexPath)
    }
}


// MARK: - Extension For ProjectHeaderViewDelegate

extension ProjectsViewController: ProjectHeaderViewDelegate {
    func didTapMenuButton(_ view: ProjectHeaderView) {
        let section = view.tag
        let project = viewModel.projects.value[section].project
        self.didTapMenu(project: project, indexSet: [section])
    }
}

