//
//  NewHabitViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 04.01.2024.
//

import UIKit

struct UserSelected {
    let category: String
    let schedule: String
}

protocol NewHabitViewControllerDelegate: AnyObject {
    func createNewHabit(header: String, tracker: Tracker)
}

//Привычка
class NewHabitViewController: UIViewController, AllCategoryViewControllerDelegate {
            
    var firstSelected = true
    var categ: Bool = false
    var shedul: Bool = false
    var habit = ""
    var dayCount = ""
    lazy var editingText = ""
    lazy var editingCategory = ""
    lazy var editingSchedule: [Weekday] = []
    var editingEmoji: String?
    var editingColor: UIColor?
    var editingID: UUID?
    
    var isEdit: Bool = false
    private var pickedCategory: TrackerCategory?
    private var settings: Array<Setting> = []
    private var allCellFilled = AllCellFilled(textField: false, tableViewCategory: false, tableViewSchedule: false, collectionViewEmoji: false, collectionViewColor: false) {
        didSet {
            updateButtonCondition()
        }
    }
    
    var isPinned: Bool = false
    
    var lastSectionIndexPath: IndexPath?
    var lastIndexPath: IndexPath?
    
    var lastSelectedEmoji: String = ""
    var lastSelectedColor: UIColor = .color1
    
    var category: String = ""
    var schedule: [Weekday] = []
    private lazy var userSelected: [String] = ["", ""]
    
    let emojiSection = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    let colorSection: [UIColor] = [UIColor.color1, UIColor.color2, UIColor.color3, UIColor.color4, UIColor.color5, UIColor.color6, UIColor.color7, UIColor.color8, UIColor.color9, UIColor.color10, UIColor.color11, UIColor.color12, UIColor.color13, UIColor.color14, UIColor.color15, UIColor.color16, UIColor.color17, UIColor.color18]
    
    var headerName: [String] = ["Emoji", localizedText(text: "color")]
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    init(delegate: NewHabitViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var textField: UITextField = {
       let textField = UITextField()
        textField.placeholder = localizedText(text: "trackerName")
        textField.clearButtonMode = .whileEditing
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.backgroundColor = .udBagroundWAD
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
        tableView.isScrollEnabled = false
        if habit == "CategoryAndSchedule" || habit == "Edit" {
            tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        } else if habit == "Category" {
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(EmojiColorCollectionCell.self, forCellWithReuseIdentifier: "emojiColorCollectionCell")
        collection.register(EmojiColorCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "emojiColorCollectionHeader")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .udDayAndNight
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
       let cancelButton = UIButton()
        cancelButton.setTitle(localizedText(text: "cancel"), for: .normal)
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
        createButton.setTitle(localizedText(text: "create"), for: .normal)
        createButton.setTitleColor(.udWhiteDay, for: .normal)
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
    
    private lazy var dayCountLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.heightAnchor.constraint(equalToConstant: 38).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udDayAndNight
        allCellFilled.tableViewSchedule = true
        if habit == "CategoryAndSchedule" {
            title = localizedText(text: "newHabbit")
        } else if habit == "Category" {
            title = localizedText(text: "newIrregular")
        } else if habit == "Edit" {
            self.navigationItem.title = localizedText(text: "editHabit")
            dayCountLabel.text = dayCount
        }
        textField.delegate = self
        setupAllViews()
        appendSettings()
        createButton.isEnabled = false
        print("Привычка")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.text = editingText
    
        // Проверяем, есть ли выбранная эмоджи
        guard let selectedEmoji = editingEmoji else {
            return
        }
        // Находим IndexPath для выбранной эмоджи в секции 0
        if let indexOfSelectedEmoji = emojiSection.firstIndex(of: selectedEmoji), indexOfSelectedEmoji < emojiSection.count {
            let indexPath = IndexPath(item: indexOfSelectedEmoji, section: 0)
            
            // Обновляем фоновый цвет ячейки
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionCell {
                cell.contentView.backgroundColor = .udLightGray
                lastSelectedEmoji = emojiSection[indexPath.item]
                print(emojiSection[indexPath.item])
                allCellFilled.collectionViewEmoji = true
            }
        }
        //Идентично для color
        guard let selectedColor = editingColor else {
            return
        }
        if let indexOfSelectedColor = colorSection.firstIndex(of: selectedColor), indexOfSelectedColor < colorSection.count {
            let indexPath = IndexPath(item: indexOfSelectedColor, section: 1)

            // Обновляем фоновый цвет ячейки
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionCell {
                cell.contentView.layer.masksToBounds = true
                cell.contentView.layer.borderWidth = 3.0
                let borderColor = colorSection[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.borderColor = borderColor
                
                lastSelectedColor = colorSection[indexPath.item]
                print(colorSection[indexPath.item])
                allCellFilled.collectionViewColor = true
            }
        }
        
        allCellFilled.tableViewSchedule = true
        allCellFilled.collectionViewColor = true
        allCellFilled.collectionViewEmoji = true
        allCellFilled.tableViewCategory = true
        allCellFilled.textField = true
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if !text.isEmpty {
            allCellFilled.textField = true
        }
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

    @objc
    private func createButtonClicked() {
        guard let trackerName = textField.text else { return }
        let irregularSchedule: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        var newHabit: Tracker
        if habit == "Edit" {
            let screen = habit == "CategoryAndSchedule" || habit == "Edit" ? editingSchedule : irregularSchedule
            newHabit = Tracker(id: editingID!, name: trackerName, color: lastSelectedColor, emoji: lastSelectedEmoji, schedule: screen, isPinned: false)
            self.delegate?.createNewHabit(header: editingCategory, tracker: newHabit)
        } else {
            let screen = habit == "CategoryAndSchedule" || habit == "Edit" ? schedule : irregularSchedule
            newHabit = Tracker(id: UUID(), name: trackerName, color: lastSelectedColor, emoji: lastSelectedEmoji, schedule: screen, isPinned: false)
            
            self.delegate?.createNewHabit(header: category, tracker: newHabit)
        }
        dismiss(animated: true)
        print("Создать")
    }
    
    func setupCategories(categories: String) {
        categoryName(name: categories)
        dismiss(animated: true)
    }
    
    private func updateButtonCondition() {
        if allCellFilled.allValuesAreTrue() {
            createButton.backgroundColor = .udNightAndDay
            createButton.setTitleColor(.udDayAndNight, for: .normal)
            createButton.isEnabled = true
        } else {
            createButton.isEnabled = false
        }
    }
    
    private func appendSettings() {
        settings.append(
            Setting(
                name: NSLocalizedString(localizedText(text: "category"), comment: ""),
                pickedParameter: isEdit ? pickedCategory?.header : nil,
                handler: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.setCategory()
                }
            ))
        if habit == "CategoryAndSchedule" || habit == "Edit" {
            settings.append(
                Setting(
                    name: NSLocalizedString(localizedText(text: "schedule"), comment: ""),
                    pickedParameter: nil,
                    handler: { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.setCategory()
                    }))
        }
        
    }
    
    private func setCategory() {
        let setCategoryController = NewCategoryViewController(delegate: self)
        present(UINavigationController(rootViewController: setCategoryController), animated: true)
    }
    
    private func setSchedule() {
        let setScheduleController = NewScheduleViewController(delegate: self)
        present(UINavigationController(rootViewController: setScheduleController), animated: true)
    }
    
    private func setupAllViews() {
        view.addSubview(dayCountLabel)
        view.addSubview(textField)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        if habit == "Edit" {
            NSLayoutConstraint.activate([
                dayCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                dayCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                dayCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                
                textField.topAnchor.constraint(equalTo: dayCountLabel.bottomAnchor, constant: 40),
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 150),
                
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
                
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
        } else {
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 150),
                
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
                
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
            
        }
    }
}

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if indexPath.row == 0 {
            let viewController = AllCategoryViewController(delegate: self, viewModel: AllCategoryViewModel())
            present(UINavigationController(rootViewController: viewController), animated: true)
        } else if indexPath.row == 1 {
            let viewController = NewScheduleViewController(delegate: self)
            present(UINavigationController(rootViewController: viewController), animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        settings[indexPath.row].handler()
    }
}

extension NewHabitViewController: UITableViewDataSource {
    //общее кол-во строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    //экземпляр ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TablewViewCell
        cell.textLabel?.text = settings[indexPath.row].name
        cell.detailTextLabel?.textColor = .udGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        if categ || shedul {
            if cell.textLabel?.text == localizedText(text: "category") {
                cell.detailTextLabel?.text = editingCategory
                categ = false
            }
            if cell.textLabel?.text == localizedText(text: "schedule") {
                cell.detailTextLabel?.text = weekdaysToString(weekdays: editingSchedule)
                shedul = false
            }
        } else {
            cell.detailTextLabel?.text = userSelected[indexPath.row]
        }
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .udBagroundWAD
        cell.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return cell
    }
}

extension NewHabitViewController: UICollectionViewDataSource {
    //кол-во секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return headerName.count
    }
    
    //кол-во ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojiSection.count
        } else {
            return colorSection.count
        }
    }
    
    //сама ячейка в выбранной indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiColorCollectionCell", for: indexPath) as? EmojiColorCollectionCell else {
            preconditionFailure("Ошибка с ячейкой")
        }
        var data: String
        if indexPath.section == 0 {
            data = emojiSection[indexPath.item]
            cell.emoji.text = data
        } else {
            cell.color.backgroundColor = colorSection[indexPath.item]
        }
        return cell
    }
    
    //Заголовок хедер
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "emojiColorCollectionHeader", for: indexPath) as! EmojiColorCollectionHeader
            headerView.titleLabel.text = headerName[indexPath.section]
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    //Выбор ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if firstSelected {
            if indexPath.section == 0 {
                if let previousCell = collectionView.cellForItem(at: IndexPath(item: emojiSection.firstIndex(of: lastSelectedEmoji) ?? 0, section: 0)) as? EmojiColorCollectionCell {
                    previousCell.contentView.backgroundColor = .clear
                }
            } else {
                if let previousCells = collectionView.cellForItem(at: IndexPath(item: colorSection.firstIndex(of: lastSelectedColor) ?? 1, section: 1)) as? EmojiColorCollectionCell {
                    previousCells.contentView.layer.borderWidth = 0.0
                    previousCells.contentView.layer.borderColor = nil
                }
                firstSelected = false
            }
        }
        guard var cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionCell else { return }
        if indexPath.section == 0 {
            cell.contentView.backgroundColor = .udLightGray
            
            lastSelectedEmoji = emojiSection[indexPath.item]
            print(emojiSection[indexPath.item])
            allCellFilled.collectionViewEmoji = true
        } else {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.borderWidth = 3.0
            let borderColor = colorSection[indexPath.item].withAlphaComponent(0.3).cgColor
            cell.contentView.layer.borderColor = borderColor
            
            lastSelectedColor = colorSection[indexPath.item]
            print(colorSection[indexPath.item])
            allCellFilled.collectionViewColor = true
        }
        
        if lastIndexPath == nil {
            lastIndexPath = indexPath
        } else {
            cell = (collectionView.cellForItem(at: lastIndexPath!) as! EmojiColorCollectionCell)
            if indexPath.section == lastIndexPath?.section {
                cell.destroyCell(lastIndexPath!)
                lastIndexPath = indexPath
            } else {
                print("Разные секции")
                if lastSectionIndexPath == nil {
                    lastSectionIndexPath = lastIndexPath
                    lastIndexPath = indexPath
                } else {
                    cell = (collectionView.cellForItem(at: lastSectionIndexPath!) as! EmojiColorCollectionCell)
                    cell.destroyCell(lastSectionIndexPath!)
                    lastSectionIndexPath = lastIndexPath
                    lastIndexPath = indexPath
                }
            }
        }
    }
    
    //Отступы от краев коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 31, right: 19)
    }
    
    //Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    //Горизонтальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    //Вертикальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //настройки Хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension NewHabitViewController: NewScheduleViewControllerDelegate {
    func getDay(day: [Weekday]) {
        editingSchedule = day
        schedule = day
        let scheduleString = weekdaysToString(weekdays: schedule)
        userSelected[1] = scheduleString
        allCellFilled.tableViewSchedule = true
        tableView.reloadData()
    }
}

extension NewHabitViewController {
    func categoryName(name: String) {
        editingCategory = name
        category = name
        userSelected[0] = category
        allCellFilled.tableViewCategory = true
        tableView.reloadData()
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return textField.resignFirstResponder()
    }
}

extension NewHabitViewController {
    
    //MARK: - Weekday to String
    func weekdaysToString(weekdays: [Weekday]) -> String {
        let weekdaysStrings = weekdays.map { weekdayToString(weekday: $0) }
        return weekdaysStrings.joined(separator: ", ")
    }
    
    func weekdayToString(weekday: Weekday) -> String {
        switch weekday {
        case .monday: return localizedText(text: "mon")
        case .tuesday: return localizedText(text: "tues")
        case .wednesday: return localizedText(text: "wed")
        case .thursday: return localizedText(text: "thurs")
        case .friday: return localizedText(text: "fri")
        case .saturday: return localizedText(text: "sat")
        case .sunday: return localizedText(text: "sun")
        }
    }
}

extension NewHabitViewController: NewCategoryViewControllerDelegate {
    func didAddNewCategory() {
        print("Заглушка")
    }
}
