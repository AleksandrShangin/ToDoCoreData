//
//  ProjectsViewController.swift
//  ToDoCoreData
//
//  Created by Alex on 4/20/21.
//

import UIKit
import Combine

final class ProjectsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var tableView: UITableView!
    
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
        self.tableView = view.tableView
    
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
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Overriden Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        viewModel.fetchProjectsAndTasks()
    }
    
    // MARK: - Bindings
    
    private func configureBindings() {
        viewModel.projects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                self.presentErrorAlert(message: error.localizedDescription)
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Actions
    
    @objc func didTapAddButton() {
        presentAddAlert(title: "New Project", updateName: nil) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.createNewProject(name: name)
        }
    }

}

// MARK: - TableView Methods

extension ProjectsViewController: UITableViewDataSource, UITableViewDelegate {

    // Sections
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.projects.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProjectHeaderView.identifier) as? ProjectHeaderView else { return nil }
        let title = viewModel.projects.value[section].project.name
        header.tag = section
        header.configure(with: title ?? "Other")
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    // Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let project = viewModel.projects.value[section].project
        return project.tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.identifier,
            for: indexPath
        ) as? TaskTableViewCell else {
            fatalError("Wrong Cell")
        }
        let task = viewModel.projects.value[indexPath.section].tasks[indexPath.row]
        let theTask = TaskViewModel(title: task.name!, isCompleted: task.isCompleted)
        cell.configure(with: theTask)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = viewModel.projects.value[indexPath.section].tasks[indexPath.row]
        
        let undoCompleteAction = UIAlertAction(title: "Undo Complete", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentAlert(title: "Undo Complete?") {
                self.viewModel.undoCompleteTask(selectedTask)
            }
        }
        
        let completeAction = UIAlertAction(title: "Complete Task", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.completeTask(selectedTask)
        }
        let updateAction = UIAlertAction(title: "Update Task", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentAddAlert(title: "Update Task", message: nil, updateName: selectedTask.name) { newName in
                self.viewModel.updateTask(selectedTask, newName: newName)
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete Task", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.presentAlert(title: "Delete Task?", message: nil) {
                self.viewModel.deleteTask(selectedTask)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let actions = !selectedTask.isCompleted ? [completeAction, updateAction, deleteAction, cancelAction] : [undoCompleteAction, updateAction, deleteAction, cancelAction]
        
        presentAlert(title: nil, message: nil, style: .actionSheet, actions: actions)
    }
    
}

// MARK: - Extension For ProjectHeaderViewDelegate

extension ProjectsViewController: ProjectHeaderViewDelegate {
    
    func didTapAddTask(_ view: ProjectHeaderView) {
        let section = view.tag
        let project = viewModel.projects.value[section].project
        presentActionSheet(section: section, project: project)
    }
    
    func presentActionSheet(section: Int, project: Project) {
        let addAction = UIAlertAction(title: "Add New Task", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presentAddAlert(title: "New Task", updateName: nil) { taskName in
                self.viewModel.createNewTask(project: project, name: taskName)
            }
        })
        
        let updateAction = UIAlertAction(title: "Update Project", style: .default, handler: { [weak self] _ in
            self?.presentAddAlert(title: "Update Project", message: nil, updateName: project.name) { newName in
                self?.viewModel.updateProject(project: project, newName: newName)
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete Project", style: .destructive, handler: { [weak self] _ in
            self?.presentAlert(title: "Delete Project?", message: nil, okHandler: {
                self?.viewModel.deleteProject(project: project)
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        presentAlert(style: .actionSheet, actions: [addAction, updateAction, deleteAction, cancelAction])
    }
    
}

