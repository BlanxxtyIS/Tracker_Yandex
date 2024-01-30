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
    
    var habit: Bool = true
    var isEdit: Bool = false
    private var pickedCategory: TrackerCategory?
    private var settings: Array<Setting> = []
    
    var lastSectionIndexPath: IndexPath?
    var lastIndexPath: IndexPath?
    
    var lastSelectedEmoji: String = ""
    var lastSelectedColor: UIColor = .color1
    
    var category: String = ""
    var schedule: [Weekday] = []
    
    let emojiSection = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    let colorSection: [UIColor] = [UIColor.color1, UIColor.color2, UIColor.color3, UIColor.color4, UIColor.color5, UIColor.color6, UIColor.color7, UIColor.color8, UIColor.color9, UIColor.color10, UIColor.color11, UIColor.color12, UIColor.color13, UIColor.color14, UIColor.color15, UIColor.color16, UIColor.color17, UIColor.color18]
    
    var headerName: [String] = ["Emoji", "Цвет"]
    
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
        if habit {
            tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        } else {
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
        return collection
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
        appendSettings()
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

    @objc
    private func createButtonClicked() {
        guard let trackerName = textField.text else { return }
        let newHabit = Tracker(id: UUID(), name: trackerName, color: lastSelectedColor, emoji: lastSelectedEmoji, schedule: schedule)
        self.delegate?.createNewHabit(header: category, tracker: newHabit)
        dismiss(animated: true)
        print("Создать")
    }
    
    private func appendSettings() {
        settings.append(
            Setting(
                name: NSLocalizedString("Категория", comment: ""),
                pickedParameter: isEdit ? pickedCategory?.header : nil,
                handler: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.setCategory()
                }
            ))
        if habit {
            settings.append(
                Setting(
                    name: NSLocalizedString("Расписание", comment: ""),
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
        
        NSLayoutConstraint.activate([
            
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
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

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewController = NewCategoryViewController(delegate: self)
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
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TableViewCell") as! TablewViewCell
           }
        cell.textLabel?.text = settings[indexPath.row].name
        cell.detailTextLabel?.text = settings[indexPath.row].pickedParameter
        cell.detailTextLabel?.textColor = .udGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .udBackground
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
        guard var cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionCell else { return }
        if indexPath.section == 0 {
            cell.contentView.backgroundColor = .udLightGray
            
            lastSelectedEmoji = emojiSection[indexPath.item]
            print(emojiSection[indexPath.item])
        } else {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.borderWidth = 3.0
            let borderColor = colorSection[indexPath.item].withAlphaComponent(0.3).cgColor
            cell.contentView.layer.borderColor = borderColor
            
            lastSelectedColor = colorSection[indexPath.item]
            print(colorSection[indexPath.item])
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
