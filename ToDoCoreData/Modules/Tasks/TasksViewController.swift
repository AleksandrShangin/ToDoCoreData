//
//  ToDoViewController.swift
//  ToDoCoreData
//
//  Created by Alex on 4/20/21.
//

import UIKit
import Combine

final class TasksViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: TasksViewModel
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let tableView = setup(UITableView(frame: .zero, style: .grouped)) {
        $0.register(ProjectHeaderView.self, forHeaderFooterViewReuseIdentifier: ProjectHeaderView.identifier)
        $0.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
    }
    
    // MARK: - Init
    
    init(viewModel: TasksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        view.backgroundColor = .systemBackground
        setupTableView()
        setupNavigationButtons()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigationButtons() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Actions
    
    @objc func didTapRightBarButton() {
        presentAddAlert(title: "New Project", updateName: nil) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.createNewProject(name: name)
        }
    }
    
    private func bind() {
        viewModel.fetchAllTasks()
        viewModel.tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }

}

// MARK: - TableView Methods

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {

    // Sections
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.tasks.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProjectHeaderView.identifier) as? ProjectHeaderView else { return nil }
        let title = viewModel.tasks.value[section].project.name
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
        let project = viewModel.tasks.value[section].project
        return project.tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.identifier,
            for: indexPath
        ) as? TaskTableViewCell else {
            fatalError("Wrong Cell")
        }
        let task = viewModel.tasks.value[indexPath.section].tasks[indexPath.row]
        let theTask = TaskViewModel(title: task.name!, isCompleted: task.isCompleted)
        cell.configure(with: theTask)
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let selectedItem = tasks[indexPath.row]
//            PersistenceManager.shared.deleteItem(item: selectedItem)
//            tasks.remove(at: indexPath.row)
//            for (index, task) in tasks.enumerated() {
//                task.index = Int64(index)
//            }
//            fetchAllTasks()
//        }
//    }

//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedItem = tasks[sourceIndexPath.row]
//        tasks.remove(at: sourceIndexPath.row)
//        tasks.insert(movedItem, at: destinationIndexPath.row)
//        for (index, task) in tasks.enumerated() {
//            task.index = Int64(index)
//        }
//        do {
//            try context.save()
//            fetchAllTasks()
//        } catch let error as NSError {
//            print("Could not save/persist Core Data items in moveRowAt: \(error)")
//        }
//
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = viewModel.tasks.value[indexPath.section].tasks[indexPath.row]
        
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
        
        presentActionSheet(title: nil, message: nil, actions: actions)
    }
    
    
}

// MARK: - Extension For ProjectHeaderViewDelegate

extension TasksViewController: ProjectHeaderViewDelegate {
    
    func didTapAddTask(_ view: ProjectHeaderView) {
        let section = view.tag
        let project = viewModel.tasks.value[section].project
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
        
        presentActionSheet(title: nil, message: nil, actions: [addAction, updateAction, deleteAction, cancelAction])
    }
    
}

