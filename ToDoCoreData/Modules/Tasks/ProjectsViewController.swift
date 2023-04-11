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
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellable)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.presentErrorAlert(message: $0.localizedDescription) }
            .store(in: &cancellable)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddButton() {
        presentAddAlert(title: "New Project", updateName: nil) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.createNewProject(name: name)
        }
    }
    
    private func didTapMenu(project: Project) {
        self.presentAlert(
            actions: [
                UIAlertAction(title: "Add New Task", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.presentAddAlert(title: "New Task", updateName: nil) { taskName in
                        self.viewModel.createNewTask(project: project, name: taskName)
                    }
                },
                UIAlertAction(title: "Rename Project", style: .default) { [weak self] _ in
                    self?.presentAddAlert(title: "Rename Project", message: nil, updateName: project.name) { newName in
                        self?.viewModel.updateProject(project: project, newName: newName)
                    }
                },
                UIAlertAction(title: "Delete Project", style: .destructive) { [weak self] _ in
                    self?.presentOkAlert(title: "Delete Project?", message: project.name, okHandler: {
                        self?.viewModel.deleteProject(project: project)
                    })
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ],
            style: .actionSheet
        )
    }
    
    private func didSelectTask(_ selectedTask: Task) {
        let undoCompleteAction = UIAlertAction(title: "Undo Complete", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentOkAlert(title: "Undo Complete?") {
                self.viewModel.undoCompleteTask(selectedTask)
            }
        }
        
        let completeAction = UIAlertAction(title: "Complete Task", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.completeTask(selectedTask)
        }
        let updateAction = UIAlertAction(title: "Rename Task", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentAddAlert(title: "Rename Task", message: nil, updateName: selectedTask.name) { newName in
                self.viewModel.renameTask(selectedTask, with: newName)
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete Task", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.presentOkAlert(title: "Delete Task?", message: selectedTask.name) {
                self.viewModel.deleteTask(selectedTask)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let actions = !selectedTask.isCompleted ? [completeAction, updateAction, deleteAction, cancelAction] : [undoCompleteAction, updateAction, deleteAction, cancelAction]
        
        presentAlert(actions: actions, style: .actionSheet)
    }

}

// MARK: - Extension For UITableViewDataSource

extension ProjectsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.projects.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueView(ProjectHeaderView.self)
        
        let projectName = viewModel.projects.value[section].project.name
        header.tag = section
        header.configure(with: projectName)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let project = viewModel.projects.value[section].project
        return project.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(TaskTableViewCell.self, for: indexPath)
        
        let task = viewModel.projects.value[indexPath.section].tasks[indexPath.row]
        let model = TaskViewModel(title: task.name, isCompleted: task.isCompleted)
        cell.configure(with: model)
        return cell
    }
    
}


// MARK: - Extension For UITableViewDelegate

extension ProjectsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = viewModel.projects.value[indexPath.section].tasks[indexPath.row]
        self.didSelectTask(selectedTask)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
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

