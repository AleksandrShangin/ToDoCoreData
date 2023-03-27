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
    
    weak var collectionView: UICollectionView!
    
    private var router: CategoriesRouter!
    private let viewModel: CategoriesViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        let view = CategoriesView()
        self.view = view
        collectionView = view.collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRouter()
        configureNavigationBar()
        configureViews()
        fetchAllCategories()
        configureBindings()
    }
    
    // MARK: - Configure
    
    private func configureRouter() {
        router = CategoriesRouter(viewController: self)
    }
    
    private func configureViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Organizer"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
    }
    
    // MARK: - Load Data
    
    private func fetchAllCategories() {
        viewModel.fetchCategories()
    }
    
    // MARK: - Bindings
    
    private func configureBindings() {
        viewModel.categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                self.presentErrorAlert(message: error.localizedDescription)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        presentAddAlert(title: "New Category", updateName: nil) { [weak self] name in
            guard let self = self else { return }
            self.viewModel.createCategory(name: name)
        }
    }
    
    private func didSelectCategory(_ selectedCategory: Category) {
        self.router.showTasks(of: selectedCategory)
    }
    
    private func didTapMenu(_ selectedCategory: Category) {
        self.presentAlert(
            actions: [
                UIAlertAction(title: "Rename Category", style: .default) { [weak self] _ in
                    self?.presentAddAlert(title: "Rename Category", message: nil, updateName: selectedCategory.name) { newName in
                        self?.viewModel.rename(selectedCategory, with: newName)
                    }
                },
                UIAlertAction(title: "Delete Category", style: .destructive) { [weak self] _ in
                    self?.presentOkAlert(title: "Delete Category?", message: selectedCategory.name, okHandler: {
                        self?.viewModel.delete(selectedCategory)
                    })
                },
                UIAlertAction(title: "Cancel", style: .cancel)
            ],
            style: .actionSheet
        )
    }

}


//MARK: - Extension for UICollectionViewDataSource

extension CategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CategoryCollectionViewCell.self, for: indexPath)
        
        let category = viewModel.categories.value[indexPath.row]
        cell.delegate = self
        cell.configure(with: category.name ?? "No Name")
        let colors = [UIColor.darkGray, UIColor.gray, UIColor.lightGray]
        cell.contentView.backgroundColor = colors[indexPath.row % colors.count]
        
        return cell
    }
    
}

//MARK: - Extension for UICollectionViewDelegate

extension CategoriesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedCategory = viewModel.categories.value[indexPath.row]
        self.didSelectCategory(selectedCategory)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: view.width - 24, height: 120)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
}

//MARK: - Extension for CategoryCollectionViewCellDelegate

extension CategoriesViewController: CategoryCollectionViewCellDelegate {
    
    func didTapMenuButton(_ cell: CategoryCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else {
            assertionFailure("Index must be set")
            return
        }
        let selectedCategory = viewModel.categories.value[index.item]
        
        self.didTapMenu(selectedCategory)
    }
    
}
