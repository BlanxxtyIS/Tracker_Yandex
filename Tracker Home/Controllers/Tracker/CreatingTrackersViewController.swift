//
//  CreatingTrackers.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 04.01.2024.
//

import UIKit

protocol CreatingTrackersDelegate: AnyObject {
    func createNewTracker(header: String, tracker: Tracker)
}

//Страница создания Привычки/Нерегулярного события
class CreatingTrackersViewController: UIViewController {
    
    weak var delegate: CreatingTrackersDelegate?
    
    init(delegate: CreatingTrackersDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var newHabitButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .udBlackDay
        let habit = NSLocalizedString("habit", comment: "Экран создания привычки")
        button.setTitle(habit, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(newHabitClick), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .udBlackDay
        let anIrregularEvent = NSLocalizedString("irregularEvent", comment: "Экран создания нерегулярного события")
        button.setTitle(anIrregularEvent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(irregularEventClick), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udWhiteDay
        let creatingTrackerTitle = NSLocalizedString("creatingTrackerTitle", comment: "Заголовок страницы создания трекера")
        title = creatingTrackerTitle
        setupAllViews()
    }
    
    private func setupAllViews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(newHabitButton)
        stackView.addArrangedSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
    }
    
    @objc private func newHabitClick() {
        let viewController = NewHabitViewController(delegate: self)
        viewController.habit = "CategoryAndSchedule"
        present(UINavigationController(rootViewController: viewController), animated:  true)
        print("Привычка")
    }
    
    @objc private func irregularEventClick() {
        let viewController = NewHabitViewController(delegate: self)
        viewController.habit = "Category"
        present(UINavigationController(rootViewController: viewController), animated:  true)
        print("Нерегулярное событие")
    }
}

extension CreatingTrackersViewController: NewHabitViewControllerDelegate {
    func createNewHabit(header: String, tracker: Tracker) {
        dismiss(animated: true)
        delegate?.createNewTracker(header: header, tracker: tracker)
    }
}
