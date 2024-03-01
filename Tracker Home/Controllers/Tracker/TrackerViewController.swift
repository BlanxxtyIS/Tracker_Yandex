//
//  TrackerViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 22.12.2023.
//


//16 Sprint
import UIKit

protocol TrackerViewControllerDelegate: AnyObject {
    func fateOfButton(whre: Bool)
}

//Трекеры
class TrackerViewController: UIViewController {
    
    //для темного/cветлого режима
    let colors = Colors()
    var selectedRowInSection0: Int?

    let trackerStore = TrackerStore.shared
    let trackerCategoryStore = TrackerCategoryStore.shared
    let trackerRecordStore = TrackerRecordStore.shared
        
    weak var delegate: TrackerViewControllerDelegate?
    
    var selectedDate = Date()
    
    var categories = TrackerCategoryStore.shared.getAllTrackerCategories()
    
    var visibleTrackers: [TrackerCategory] = []
    
    //Выполненные трекеры
    var completedTrackers: [TrackerRecord] = []
    
    //MARK: Empty and Error Views
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        let emptyStateText = NSLocalizedString("emptyState.title", comment: "Текст пустого экрана")
        label.text = emptyStateText
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyImage: UIImageView = {
        let image = UIImage(named: "Empty Image")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - UI Elements
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .udBlue
        picker.addTarget(self, action: #selector(datePickerSelected), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchBar: UISearchTextField = {
        let search = UISearchTextField()
        search.delegate = self
        search.textColor = .udBlackDay
        let searchPlaceholder = NSLocalizedString("searchPlaceholder", comment: "Текст поиска на UISearchTextField")
        search.placeholder = searchPlaceholder
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerViewControllerCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(TrackerViewControllerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        //Чтобы коллекция знала, что нужно выбирать лишь одну ячейку
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK: - Functional
    override func viewDidLoad() {
        super.viewDidLoad()
        visibleTrackers = categories
        view.backgroundColor = UIColor.udWhiteDay
        settingNavBarItems()
        setupAllViews()
        setupAllConstraints()
        updateViewController()
        datePickerSelected(datePicker)
        print(trackerRecordStore.fetchAllRecord())
    }
        
    @objc func datePickerSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateVisibleTrackers(forDate: selectedDate)
    }
    
    func updateVisibleTrackers(forDate: Date) {
        let components = datePicker.calendar.dateComponents([.day, .weekday], from: datePicker.date)
        guard let weekday = components.weekday else {
            return
        }
         //Воскресенье - 1, Понедельник - 2
        var searchedCategories: [TrackerCategory] = []
        for category in categories {
            var searchedTrackers: [Tracker] = []
            
            for tracker in category.tracker {
                guard let day = Weekday(rawValue: weekday) else { return }
                if tracker.schedule.contains(day) {
                    searchedTrackers.append(tracker)
                }
            }
            if !searchedTrackers.isEmpty {
                searchedCategories.append(TrackerCategory(header: category.header, tracker: searchedTrackers, id: UUID()))
            }
        }
        visibleTrackers = searchedCategories
        collectionView.reloadData()
        updateViewController()
    }
        
    @objc private func addTracker() {
        let viewController = CreatingTrackersViewController(delegate: self)
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    //Метод делегата на получение категории
    func categoryName(name: String) {
        print(name)
    }
    
    //Обновление экрана
    private func updateViewController() {
        if visibleTrackers.isEmpty {
            collectionView.isHidden = false
            setupEmptyErrorViews()
            emptyView(true)
        } else {
            setupAllViews()
            setupAllConstraints()
        }
    }
    
    //Настройка navigationBar (кнопка + и datePicker)
    private func settingNavBarItems() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "Add tracker"), style: .plain, target: self, action: #selector(addTracker))
        plusButton.tintColor = .udBlackDay
        
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    //Установка всех view
    private func setupAllViews(){
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    //Установка всех констрейнтов
    private func setupAllConstraints(){
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    //Установка пустого/ошибочного экрана (заглушка)
    private func setupEmptyErrorViews() {
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 230),
            emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8)
            ])
    }
    
    private func errorView(_ result: Bool) {
        emptyImage.image = UIImage(named: "Error Image")
        let errorSearchText = NSLocalizedString("errorSearchText", comment: "Текст при ошибке поиска")
        emptyLabel.text = errorSearchText
        
        if result {
            // to show
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
        } else {
            // to dismiss
            emptyImage.isHidden = true
            emptyLabel.isHidden = true
        }
    }
    
    private func emptyView(_ result: Bool) {
        emptyImage.image = UIImage(named: "Empty Image")
        let emptyStateText = NSLocalizedString("emptyState.title", comment: "Текст пустого экрана")
        emptyLabel.text = emptyStateText
        
        if result {
            // to show
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
        } else {
            // to dismiss
            emptyImage.isHidden = true
            emptyLabel.isHidden = true
        }
    }
    
    //Установка заглушки при пустом/неверном поиске
    //MARK: - после пустого поиск
    private func setupPlugView() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            updateVisibleTrackers(forDate: datePicker.date)
            errorView(visibleTrackers.isEmpty)
            visibleTrackers.isEmpty ? emptyView(true) : collectionView.reloadData()
            collectionView.reloadData()
            return
        }
        var searchedCategories: [TrackerCategory] = []
        for category in categories {
            var searchedTrackers: [Tracker] = []
            
            for tracker in category.tracker {
                if tracker.name.localizedCaseInsensitiveContains(searchText) {
                    searchedTrackers.append(tracker)
                }
            }
            if !searchedTrackers.isEmpty {
                searchedCategories.append(TrackerCategory(header: category.header, tracker: searchedTrackers, id: UUID()))
            }
        }
        visibleTrackers = searchedCategories
        updateViewController()
        errorView(visibleTrackers.isEmpty)
        collectionView.reloadData()
    }
    
    //Выполнен ли в данный день
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let allRecords = trackerRecordStore.fetchAllRecord()
        return allRecords.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date!, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
}

//Расширение SearchBara, возвращает текст работает с экраном
extension TrackerViewController: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setupPlugView()
        collectionView.reloadData()
        return true
    }
    
    //динамическое обновление
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            print("Текущий текст: \(currentText)")
            setupPlugView()
            collectionView.reloadData()
        }
        return true
    }
}

//MARK: UICollectionViewCell - Header
extension TrackerViewController: UICollectionViewDataSource, TrackerViewControllerCellDelegate {
    //MARK: - НАДО сохранить старый хедер, удалить трекер, создавть новый в "Закрепленные", При откреплении все тоже самое только, передадим туда старый хедер
    func pinnedTracker(id: UUID, indexPath: IndexPath) {
        print("Надо закрепить")
        let header = "Закрепленные"
        var oldHeader = ""
        if let trackerCD = trackerStore.fetchTracker(withID: id) {
            if let foundCategory = categories.first(where: { $0.tracker.contains { $0.id == id } }) {
                oldHeader = foundCategory.header
            }
            let tracker = trackerStore.trackerFromCoreData(trackerCD)
            createNewTracker(header: header, tracker: tracker)
            trackerCategoryStore.deleteTracker(trackerCoreData: trackerCD)
        }
        updateTrackerViews()
    }
    
    func unPinnedTracker(id: UUID, indexPath: IndexPath) {
        print("Надо открепить")
        var header = ""
        if let trackerCD = trackerStore.fetchTracker(withID: id) {
            let tracker = trackerStore.trackerFromCoreData(trackerCD)
            createNewTracker(header: header, tracker: tracker)
            trackerCategoryStore.deleteTracker(trackerCoreData: trackerCD)
        }
    }
    
    func removeTracker(id: UUID, indexPath: IndexPath) {
        if let trackerCD = trackerStore.fetchTracker(withID: id) {
            trackerCategoryStore.deleteTracker(trackerCoreData: trackerCD)
            updateTrackerViews()
            print("Удалить")
        }
    }
    
    
    func editTracker(id: UUID, indexPath: IndexPath) {
        editHabit(indexPath, id: id)
        print("Изменить")
    }
    
    private func editHabit(_ indexPath: IndexPath, id: UUID) {
        let viewController = NewHabitViewController(delegate: self)
        viewController.habit = "Edit"
        if let trackerCD = trackerStore.fetchTracker(withID: id) {
            if let foundCategory = categories.first(where: { $0.tracker.contains { $0.id == id } }) {
                if let tracker = foundCategory.tracker.first(where: { $0.id == id }) {
                    viewController.editingTextField = tracker.name
                    viewController.editingSchedule = tracker.schedule
                    viewController.selectedColorIndexes = tracker.color
                    viewController.selectedEmojiIndexes = tracker.emoji
                }
                viewController.editingCategory = foundCategory.header
            }
        }
        present(UINavigationController(rootViewController: viewController), animated: true)
    }

    func completeTracker(id: UUID, indexPath: IndexPath) {
        if let createdDate = trackerStore.fetchTracker(withID: id)?.createdDate {
            let calendar = Date()
            let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
            
            if selectedDate > calendar {
                print("ЗАГЛУШКА")
            } else {
                print("Можно")
                let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
                completedTrackers.append(trackerRecord)
                trackerRecordStore.trackerRecordConvert(trackerRecord)
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }

    func uncompleteTracker(id: UUID, indexPath: IndexPath) {
        trackerRecordStore.removeRecord(forId: id, onDate: datePicker.date)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func reload(id: UUID, indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedRowInSection0 = indexPath.row
        }
        print("Нажали на ячейку \(indexPath)")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {        return visibleTrackers.count
    }
    
    //Кол-во ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleTrackers[section].tracker.count
    }
    
    //Сама ячейка для заданной позиции
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerViewControllerCell else {
            preconditionFailure("Ошибка с ячейкой")
        }
        let tracker = visibleTrackers[indexPath.section].tracker[indexPath.row]
        
        let allRecords = trackerRecordStore.fetchAllRecord()
        var completedDay = allRecords.filter { $0.id == tracker.id}.count
        var completedToday = isTrackerCompletedToday(id: tracker.id)
        
        cell.setupData(traker: tracker, dayCount: completedDay, isCompletedToday: completedToday, indexPath: indexPath)
        cell.delegate = self
        cell.selectedDate = selectedDate
        return cell
    }
}

//Для управления расположением и размерами элементов
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    //Метод чтобы мы могли возвращать хедер для каждой секции
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackerViewControllerHeader
            
        view.titleLabel.text = visibleTrackers.isEmpty ? "" : visibleTrackers[indexPath.section].header
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 16, left: 28, bottom: 12, right: 28)
        return CGSize(width: collectionView.bounds.width - sectionInsets.left - sectionInsets.right, height: 18)
    }
    
    //Высота и ширина ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    //Отступы от краев коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    //Горизонтальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    //Вертикальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//Делегат на добавление нового трекера
extension TrackerViewController: CreatingTrackersDelegate {
    func createNewTracker(header: String, tracker: Tracker) {
        let newTracker = TrackerCategory(header: header, tracker: [tracker], id: UUID())
        if let categoryCoreData = trackerCategoryStore.fetchTrackerCategory(with: header) {
            print("Есть такая шляпка в CoreData")
            //НАДО ЕЙ ДОБАВИТЬ ТРЭКЕР
            let trackerCD = trackerStore.trackerConvert(tracker)
            trackerStore.addTrackerToCategory(tracker: trackerCD, category: categoryCoreData)
        } else {
            print("Нету такой шляпки в CoreData")
            //Надо добавить полную категорию
            trackerCategoryStore.addTrackerCategory(trackerCategory: newTracker, trackers: [tracker])
        }
        updateTrackerViews()
    }
    
    func updateTrackerViews() {
        categories = TrackerCategoryStore.shared.getAllTrackerCategories()
        visibleTrackers = categories
        collectionView.reloadData()
        updateVisibleTrackers(forDate: datePicker.date)
    }
}
    

extension TrackerViewController: NewHabitViewControllerDelegate {
    func createNewHabit(header: String, tracker: Tracker) {
        print("yoooou")
        print(header)
        print(tracker)
    }
}





