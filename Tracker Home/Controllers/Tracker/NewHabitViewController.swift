//
//  NewHabitViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 04.01.2024.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func createNewHabit(header: String, tracker: Tracker)
}

//Привычка
class NewHabitViewController: UIViewController {
    
    var category: String = ""
    var schedule: [Weekday] = []
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    init(delegate: NewHabitViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var habit: [String] = ["Категория", "Расписание"]
    
    private lazy var textField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.backgroundColor = .udBackground
        textField.layer.cornerRadius = 16
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(TablewViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .udBackground
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
       let cancelButton = UIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.udRed.cgColor
        cancelButton.setTitleColor(.udRed, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return cancelButton
    }()
    
        private lazy var createButton: UIButton = {
           let createButton = UIButton()
            createButton.setTitle("Создать", for: .normal)
            createButton.backgroundColor = .udGray
            createButton.layer.cornerRadius = 16
            createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            createButton.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
            createButton.translatesAutoresizingMaskIntoConstraints = false
            createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            return createButton
        }()
    
    private lazy var buttonStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udWhiteDay
        title = "Новая привычка"
        textField.delegate = self
        setupAllViews()
        print("Привычка")
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 38 {
            textField.deleteBackward()
            print("Ограничение 38 символов")
        }
    }
    
    @objc
    private func cancelButtonClicked() {
        dismiss(animated: true)
        print("Отменить")
    }

    //MARK: ДОБАВИТЬ ДЕЛЕГАТ на schedule и обновить таблицу
    //Создаем новый трекер
    @objc
    private func createButtonClicked() {
        guard let trackerName = textField.text else { return }
        let newHabit = Tracker(id: UUID(), name: trackerName, color: .colorSelection18, emoji: "❤️️️️️️️", schedule: schedule)
        self.delegate?.createNewHabit(header: category, tracker: newHabit)
        dismiss(animated: true)
        print("Создать")
    }
    
    private func setupAllViews() {
        view.addSubview(textField)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
        
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
    }
}

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Категория")
            let viewController = NewCategoryViewController(delegate: self)
            present(UINavigationController(rootViewController: viewController), animated: true)
        } else if indexPath.row == 1 {
            let viewController = NewScheduleViewController(delegate: self)
            present(UINavigationController(rootViewController: viewController), animated: true)
            print("Расписание")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewHabitViewController: UITableViewDataSource {
    //общее кол-во строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habit.count
    }
    
    //экземпляр ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TablewViewCell
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TableViewCell") as! TablewViewCell
           }
        cell.textLabel?.text = self.habit[indexPath.row]
        cell.detailTextLabel?.text = "Подтекст"
        cell.detailTextLabel?.textColor = .udGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .udBackground
        cell.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return cell
    }
}

extension NewHabitViewController: NewScheduleViewControllerDelegate {
    func getDay(day: [Weekday]) {
        schedule = day
    }
}

extension NewHabitViewController: NewCategoryViewControllerDelegate {
    func categoryName(name: String) {
        category = name
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
