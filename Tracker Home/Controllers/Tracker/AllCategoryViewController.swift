//
//  AllCategoryViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.02.2024.
//

import UIKit

protocol AllCategoryViewControllerDelegate: AnyObject {
    func setupCategories(categories: String)
}

class AllCategoryViewController: UIViewController, NewCategoryViewControllerDelegate {
    
    private var viewModel: AllCategoryViewModel!
    
    weak var delegate: AllCategoryViewControllerDelegate?
    init(delegate: AllCategoryViewControllerDelegate?, viewModel: AllCategoryViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var categoryStore = CategoryStore.shared
    private var categories: [String] = []
    
    private lazy var emptyImage: UIImageView = {
       let image = UIImage(named: "Empty Image")
        let emptyImage = UIImageView(image: image)
        emptyImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        emptyImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        return emptyImage
    }()
    
    private lazy var emptyLabel: UILabel = {
       let label = UILabel()
        let emptyCategoryText = NSLocalizedString("emptyCategoryText", comment: "Текст пустого экрана")
        label.text = emptyCategoryText
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(AllCategoryViewControllerCell.self, forCellReuseIdentifier: "AllCategoryViewControllerCell")
        table.separatorStyle = .singleLine
        table.separatorColor = .udGray
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = .udWhiteDay
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        let cgColor = UIColor.udWhiteDay.cgColor
        table.layer.borderColor = cgColor
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var addCategoryButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .udBlackDay
        let addCategoryButtonText = NSLocalizedString("addCategoryButtonText", comment: "Кнопка добавить категорию")
        button.setTitle(addCategoryButtonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udWhiteDay
        let categoryTitle = NSLocalizedString("categoryTitle", comment: "текст заголовка")
        title = categoryTitle
        view.addSubview(addCategoryButton)
        categories = categoryStore.categoryGive()
        tableView.delegate = self
        tableView.dataSource = self
        if categories.isEmpty {
            setupEmptyView()
        } else {
            setupView()
        }
        setupViewModel()
        viewModel.loadData()
    }
    
    @objc
    private func addButtonClicked() {
        let vc = NewCategoryViewController(delegate: self)
        present(UINavigationController(rootViewController: vc), animated: true)
        print("Перешли")
    }
    
    private func setupViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                if self?.viewModel.categories.isEmpty ?? true {
                    self?.setupEmptyView()
                } else {
                    self?.setupView()
                }
            }}
    }
    
    func didAddNewCategory() {
        viewModel.loadData()
        dismiss(animated: true)
    }
    
    private func updateCategories() {
        categories = categoryStore.categoryGive()
        tableView.reloadData()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -18)])
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLabel.widthAnchor.constraint(equalToConstant: 180),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8)])
    }
}

extension AllCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        delegate?.setupCategories(categories: viewModel.categories[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AllCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "AllCategoryViewControllerCell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "AllCategoryViewControllerCell")
        }
        cell.textLabel?.text = viewModel.categories[indexPath.row].name
        cell.backgroundColor = .udBackground
        let height = tableView.bounds.height / 7
        print(height)
        cell.heightAnchor.constraint(equalToConstant: height).isActive = true
        return cell
    }
}
    
