//
//  NewCategoryViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 05.01.2024.
//

import UIKit

//Категория
class NewCategoryViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Новая категория"
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "   Введите название категории"
        textField.backgroundColor = .udBackground
        textField.layer.cornerRadius = 16
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .udGray
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udWhiteDay
        setupAllViews()
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count >= 1 {
            textField.rightViewMode = .always
            readyButton.backgroundColor = .udBlackDay
            readyButton.setTitle("Добавить категорию", for: .normal)
            readyButton.isEnabled = true
        } else {
            textField.rightViewMode = .never
            readyButton.backgroundColor = .udGray
            readyButton.isEnabled = false
        }
    }
    
    @objc
    private func addTracker() {
        dismiss(animated: true)
        guard let category = textField.text else { return }
        print(category)
    }
    
    private func setupAllViews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
        
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)])
    }
}

