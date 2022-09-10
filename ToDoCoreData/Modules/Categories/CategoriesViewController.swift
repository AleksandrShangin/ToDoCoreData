//
//  MainViewController.swift
//  ToDoCoreData
//
//  Created by Alex on 11/21/21.
//

import UIKit
import Combine

final class CategoriesViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = CategoriesViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let tableView = setup(UITableView()) {
        $0.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        $0.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupTableView()
        fetchAllCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigationItems() {
        navigationItem.title = viewModel.title
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - Fetch Data
    
    private func fetchAllCategories() {
        viewModel.fetchCategories()
        viewModel.categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }.store(in: &subscriptions)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        presentAddAlert(title: "New Category", updateName: nil) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.addNewCategory(name: name)
        }
    }

}

// MARK: - TableView Methods

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Sections
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.categories.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else { return UITableViewCell() }
        let category = viewModel.categories.value[indexPath.section]
        cell.delegate = self
        cell.configure(with: category.name ?? "No Name")
        let colors = [UIColor.darkGray, UIColor.gray, UIColor.lightGray]
        cell.contentView.backgroundColor = colors[indexPath.section % colors.count]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = viewModel.categories.value[indexPath.section]
        let tasksViewModel = TasksViewModel(category: category)
        let tasksViewController = TasksViewController(viewModel: tasksViewModel)
        tasksViewController.title = category.name ?? "No Category"
        navigationController?.pushViewController(tasksViewController, animated: true)
    }
    
}


// MARK: - Extension For CategoryTableViewCellDelegate

extension CategoriesViewController: CategoryTableViewCellDelegate {
    
    func didTapMenu(_ cell: CategoryTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.section else {
            assertionFailure("Index must be set")
            return
        }
        let selectedCategory = viewModel.categories.value[index]
        self.presentActionSheet(category: selectedCategory)
    }
    
    func presentActionSheet(category: Category) {
        let renameAction = UIAlertAction(title: "Rename Category", style: .default) { [weak self] _ in
            self?.presentAddAlert(title: "Rename Category", message: nil, updateName: category.name) { newName in
                self?.viewModel.update(category, name: newName)
            }
        }
        let deleteAction = UIAlertAction(title: "Delete Category", style: .destructive) { [weak self] _ in
            self?.presentAlert(title: "Delete Project?", message: nil, okHandler: {
                self?.viewModel.delete(category)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        presentActionSheet(title: nil, message: nil, actions: [renameAction, deleteAction, cancelAction])
    }
    
}
