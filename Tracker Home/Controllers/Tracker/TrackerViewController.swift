//
//  TrackerViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 22.12.2023.
//


//16 Sprint
import UIKit
import AppMetricaCore

//Трекеры
class TrackerViewController: UIViewController {
    
    var selectedFilters: String = ""
    
    private let analyticsService = AnalyticsService()
    
    let trackerStore = TrackerStore.shared
    let trackerCategoryStore = TrackerCategoryStore.shared
    let trackerRecordStore = TrackerRecordStore.shared
    
    var selectedDate = Date()
    
    var categories = TrackerCategoryStore.shared.getAllTrackerCategories()
    
    var visibleTrackers: [TrackerCategory] = []
    
    //Выполненные трекеры
    var completedTrackers: [TrackerRecord] = []
    
    //MARK: Empty and Error Views
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = localizedText(text: "emptyTraker")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udNightAndDay
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
        search.placeholder = localizedText(text: "search")
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerViewControllerCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(TrackerViewControllerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .udDayAndNight
        return collectionView
    }()
    
    private lazy var filtrButton: UIButton = {
        let button = UIButton()
        button.setTitle(localizedText(text: "filters"), for: .normal)
        button.backgroundColor = .udBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Functional
    override func viewDidLoad() {
        super.viewDidLoad()
        sorted()
        view.backgroundColor = .udDayAndNight
        settingNavBarItems()
        setupAllViews()
        setupAllConstraints()
        updateViewController()
        let trackerRecordCD = trackerRecordStore.fetchAllRecord()
        completedTrackers = trackerRecordStore.trackerRecordConver(trackerRecordCD)
        
    }
    
    private func sorted() {
        categories.forEach({ categ in
            if categ.tracker.isEmpty {
                print("MISS")
            } else {
                visibleTrackers.append(categ)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open TrackersViewController", parameters: ["event": "open", "screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "closed TrackersViewController", parameters: ["event": "close", "screen": "Main"])
    }
    
    @objc func datePickerSelected(_ sender: UIDatePicker) {
        analyticsService.report(event: "Date picker date changed on TrackersViewController", parameters: ["event": "change", "screen": "Main"])
        selectedDate = sender.date
        updateVisibleTrackers(forDate: selectedDate)
        visibleTrackers.isEmpty ? emptyView(true) : errorView(false)
    }
    
    func updateVisibleTrackers(forDate: Date) {
        if selectedFilters.isEmpty {
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
        } else {
            filterSetting(Int(selectedFilters)!)
        }
    }
    
    @objc private func addTracker() {
        let viewController = CreatingTrackers(delegate: self)
        present(UINavigationController(rootViewController: viewController), animated: true)
        analyticsService.report(event: "Add tracker tapped on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "add_track"])
    }
    
    @objc func filterButtonClicked(_ sender: UIButton) {
        let vc = UINavigationController(rootViewController: FilterViewController(delegate: self))
        present(vc, animated: true)
        analyticsService.report(event: "Did press the filters button on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "filter"])
        print("Фильтр, фильтр")
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
        plusButton.tintColor = .udNightAndDay
        
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    //Установка всех view
    private func setupAllViews(){
        filtrButton.isHidden = false
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(filtrButton)
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
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            filtrButton.heightAnchor.constraint(equalToConstant: 50),
            filtrButton.widthAnchor.constraint(equalToConstant: 114),
            filtrButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtrButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
        emptyLabel.text = localizedText(text: "empteSearch")
        
        if result {
            // to show
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
            filtrButton.isHidden = true
        } else {
            // to dismiss
            filtrButton.isHidden = false
            emptyImage.isHidden = true
            emptyLabel.isHidden = true
        }
    }
    
    private func emptyView(_ result: Bool) {
        emptyImage.image = UIImage(named: "Empty Image")
        emptyLabel.text = localizedText(text: "emptyTraker")
        
        if result {
            // to show
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
            filtrButton.isHidden = true
        } else {
            // to dismiss
            filtrButton.isHidden = false
            emptyImage.isHidden = true
            emptyLabel.isHidden = true
        }
    }
    
    //Установка заглушки при пустом/неверном поиске
    //MARK: - после пустого поиск
    private func setupPlugView() {
        if selectedFilters.isEmpty {
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
        } else {
            filterSetting(Int(selectedFilters)!)
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                updateVisibleTrackers(forDate: datePicker.date)
                errorView(visibleTrackers.isEmpty)
                visibleTrackers.isEmpty ? emptyView(true) : collectionView.reloadData()
                collectionView.reloadData()
                return
            }
            var searchedCategories: [TrackerCategory] = []
            for category in visibleTrackers {
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
    }
    
    //Выполнен ли в данный день
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let allRecords = trackerRecordStore.fetchAllRecord()
        return allRecords.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date!, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    func updateTrackerViews() {
        categories = TrackerCategoryStore.shared.getAllTrackerCategories()
        visibleTrackers = categories
        collectionView.reloadData()
        updateVisibleTrackers(forDate: datePicker.date)
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
            if currentText.count == 0 {
                updateVisibleTrackers(forDate: datePicker.date)
                collectionView.reloadData()
                return true
            } else {
                print("Текущий текст: \(currentText)")
                setupPlugView()
                collectionView.reloadData()
            }
        }
        return true
    }
}

//MARK: UICollectionViewCell - Header
extension TrackerViewController: UICollectionViewDataSource, TrackerViewControllerCellDelegate {
    func toFix(id: UUID) {
        if var (category, tracker) = trackerCategoryStore.getAllTrackerCategories()
            .flatMap({ category in category.tracker.map { (category, $0) } })
            .first(where: { $0.1.id == id }) {
            print("Найден трекер \(tracker) в категории \(category.header)")
            if tracker.isPinned {
                let removedTracker = trackerStore.fetchTracker(withID: id)
                let newTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, isPinned: false)
                let oldHeader = UserDefaults.standard.string(forKey: "\(id)")!
                createNewTracker(header: oldHeader, tracker: newTracker)
                trackerCategoryStore.deleteTracker(trackerCoreData: removedTracker!)
            } else {
                let newTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, isPinned: true)
                UserDefaults.standard.set(category.header, forKey: "\(id)")
                UserDefaults.standard.synchronize()
                let removedTracker = trackerStore.fetchTracker(withID: id)
                createNewTracker(header: localizedText(text: "fixed"), tracker: newTracker)
                trackerCategoryStore.deleteTracker(trackerCoreData: removedTracker!)
            }
        } else {
            print("Трекер \(id) не найден")
        }
        updateTrackerViews()
    }

    
    func toEdit(id: UUID, dayLabel: String) {
        if let (category, tracker) = trackerCategoryStore.getAllTrackerCategories()
            .flatMap({ category in category.tracker.map { (category, $0) } })
            .first(where: { $0.1.id == id }) {
            print("Найден трекер \(tracker) в категории \(category.header)")
            let vc = NewHabitViewController(delegate: self)
            vc.habit = "Edit"

            vc.dayCount = dayLabel
            vc.editingText = tracker.name
            vc.editingCategory = category.header
            vc.editingSchedule = tracker.schedule
            vc.editingEmoji = tracker.emoji
            vc.editingColor = tracker.color
            vc.categ = true
            vc.shedul = true
            vc.editingID = id
            present(vc, animated: true)
        } else {
            print("Трекер \(id) не найден")
        }
        updateTrackerViews()
    }
    
    func toRemove(id: UUID) {
        if let trackerCD = trackerStore.fetchTracker(withID: id) {
            trackerCategoryStore.deleteTracker(trackerCoreData: trackerCD)
        }
        updateTrackerViews()
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
        let allRecordCD = trackerRecordStore.fetchAllRecord()
        let allRecord = trackerRecordStore.trackerRecordConver(allRecordCD)
        completedTrackers = allRecord
        collectionView.reloadItems(at: [indexPath])
    }
    
    func reload(id: UUID, indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.analyticsService.report(event: "Did tap tracker cell", parameters: ["event": "click", "screen": "Main", "item": "cell"])
        print("\(indexPath.row) нажали на ячейку реализация в дальнейшем мб")
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
        let completedDay = allRecords.filter { $0.id == tracker.id}.count
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
        categories = TrackerCategoryStore.shared.getAllTrackerCategories()
        visibleTrackers = categories
        collectionView.reloadData()
        updateViewController()
        updateVisibleTrackers(forDate: datePicker.date)
    }
}

extension TrackerViewController: NewHabitViewControllerDelegate {
    func createNewHabit(header: String, tracker: Tracker) {
        toRemove(id: tracker.id)
        createNewTracker(header: header, tracker: tracker)
        print("Заглушка")
    }
}

extension TrackerViewController: FilterViewControllerProtocol {
    func filterSetting(_ setting: Int) {
        switch setting {
        case 0:
            //Отображаются все трекеры на выбранный день в клаендаре
            print("Все трекеры")
            updateVisibleTrackers(forDate: datePicker.date)
            collectionView.reloadData()
        case 1:
            print("Трекеры на сегодня")
            selectedFilters = ""
            //Отображаются все трекеры на Текущую дату
            datePicker.setDate(Date(), animated: false)
            updateVisibleTrackers(forDate: datePicker.date)
            collectionView.reloadData()
        case 2:
            print("Завершенные")
            selectedFilters = "2"
            sortReadyOrNotTracker(isIt: true)
        case 3:
            print("Не завершенные")
            selectedFilters = "3"
            let visibleTrackersMock = visibleTrackers
            visibleTrackers = []
            let category = trackerCategoryStore.getAllTrackerCategories()
            category.forEach({ category in
                category.tracker.forEach({ tracker in
                    if completedTrackers.contains(where: {$0.id == tracker.id}) {
                        print("Есть")
                    } else {
                        let nonCompletedCategory = TrackerCategory(header: category.header, tracker: [tracker], id: UUID())
                        if !visibleTrackers.contains(where: {$0.header == nonCompletedCategory.header}) {
                            visibleTrackers.append(nonCompletedCategory)
                        } else {
                            for i in 0..<visibleTrackers.count {
                                if visibleTrackers[i].header == nonCompletedCategory.header {
                                    visibleTrackers[i].tracker.append(contentsOf: nonCompletedCategory.tracker)
                                }
                            }
                        }
                        collectionView.reloadData()
                    }
                })
            })
            let components = datePicker.calendar.dateComponents([.day, .weekday], from: datePicker.date)
            guard let weekday = components.weekday else {
                return
            }
            var searchedCategories: [TrackerCategory] = []
            for category in visibleTrackers {
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
            updateViewController()
            collectionView.reloadData()
        default:
            var allTracker: [TrackerCategory] = []
            categories = TrackerCategoryStore.shared.getAllTrackerCategories()
            categories.forEach({
                if $0.tracker.isEmpty {
                    print("Пустой заголовок")
                } else {
                    allTracker.append($0)
                }
            })
            collectionView.reloadData()
            print("Ошибочка")
        }
    }
    
    func sortReadyOrNotTracker(isIt: Bool) {
        categories = TrackerCategoryStore.shared.getAllTrackerCategories()
        var allRecord: [TrackerCategory] = []
        visibleTrackers = []
        
        categories.forEach { category in
            let filteredTrackers = category.tracker.filter { isTrackerCompletedToday(id: $0.id) }
            if !filteredTrackers.isEmpty {
                // Добавляем отфильтрованные трекеры в общий список
                guard let trackerCD = trackerCategoryStore.fetchTrackerCategory(withID: category.id) else { return }
                let filteredCategory = TrackerCategory(header: category.header, tracker: filteredTrackers, id: UUID())
                print("Существуют завершенные трекеры в этот день в категории: \(category.header), \(filteredCategory)")
                    allRecord.append(filteredCategory)
            } else {
                print("Нет завершенных трекеров в этот день в категории: \(category.header)")
            }
        }
        visibleTrackers = allRecord
        updateViewController()
        collectionView.reloadData()
    }
}





