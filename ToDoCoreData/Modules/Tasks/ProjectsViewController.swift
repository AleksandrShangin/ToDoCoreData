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
            .sink { [weak self] in self?.presentErrorAlert(message: $0.localizedDescription) }
            .store(in: &cancellable)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddButton() {
        presentAddAlert(title: L10n.Project.new) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.createNewProject(name: name)
        }
    }
    
    private func didTapMenu(project: Project) {
        self.presentAlert(
            actions: [
                UIAlertAction(title: L10n.Task.addNew, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.presentAddAlert(title: L10n.Task.new) { taskName in
                        self.viewModel.createNewTask(project: project, name: taskName)
                    }
                },
                UIAlertAction(title: L10n.Project.rename, style: .default) { [weak self] _ in
                    self?.presentAddAlert(title: L10n.Project.rename, updateName: project.name) { newName in
                        self?.viewModel.updateProject(project: project, newName: newName)
                    }
                },
                UIAlertAction(title: L10n.Project.delete, style: .destructive) { [weak self] _ in
                    self?.presentOkAlert(title: "\(L10n.Project.delete)?", message: project.name, okHandler: {
                        self?.viewModel.deleteProject(project: project)
                    })
                },
                UIAlertAction(title: L10n.Common.cancel, style: .cancel)
            ],
            style: .actionSheet
        )
    }
    
    private func didSelectTask(_ selectedTask: Task) {
        let undoCompleteAction = UIAlertAction(title: L10n.Task.undoComplete, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentOkAlert(title: "\(L10n.Task.undoComplete)?") {
                self.viewModel.undoCompleteTask(selectedTask)
            }
        }
        
        let completeAction = UIAlertAction(title: L10n.Task.complete, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.completeTask(selectedTask)
        }
        let updateAction = UIAlertAction(title: L10n.Task.rename, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentAddAlert(title: L10n.Task.rename, updateName: selectedTask.name) { newName in
                self.viewModel.renameTask(selectedTask, with: newName)
            }
        }
        
        let deleteAction = UIAlertAction(title: L10n.Task.delete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.presentOkAlert(title: "\(L10n.Task.delete)?", message: selectedTask.name) {
                self.viewModel.deleteTask(selectedTask)
            }
        }
        
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        
        let actions = !selectedTask.isCompleted ? [completeAction, updateAction, deleteAction, cancelAction] : [undoCompleteAction, updateAction, deleteAction, cancelAction]
        
        presentAlert(actions: actions, style: .actionSheet)
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
        self.didSelectTask(selectedTask)
    }
}


// MARK: - Extension For ProjectHeaderViewDelegate

extension ProjectsViewController: ProjectHeaderViewDelegate {
    func didTapMenuButton(_ view: ProjectHeaderView) {
        let section = view.tag
        let project = viewModel.projects.value[section].project
        self.didTapMenu(project: project)
    }
}

