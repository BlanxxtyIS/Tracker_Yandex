//
//  StatisticsViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 22.12.2023.
//

import UIKit


//Статистика
class StatisticsViewController: UIViewController {
    
    var dayCount = ""
    let trackerRecord = TrackerRecordStore.shared.fetchAllRecord()
    let gradient = CAGradientLayer()
    
    //MARK: Empty and Error Views
    private lazy var emptyLabel: UILabel = {
       let label = UILabel()
        label.text = localizedText(text: "emptyStatistics")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udNightAndDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var emptyImage: UIImageView = {
        let image = UIImage(named: "Empty Statistics")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var readyView: UIView = {
        let view = UIView()
        view.backgroundColor = .udDayAndNight
        view.layer.cornerRadius = 16
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayCuntLabel: UILabel = {
       let label = UILabel()
        label.text = dayCount
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .udNightAndDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var endTracker: UILabel = {
        let label = UILabel()
        label.text = "Трекеров завершено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udNightAndDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udDayAndNight
        print("\(trackerRecord.count)")
        dayCount = "\(UserDefaults.standard.integer(forKey: "DayCount"))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackerRecord.isEmpty ? setupEmptyErrorViews() : setupViews()
        dayCount = "\(UserDefaults.standard.integer(forKey: "DayCount"))"
        let gradietn = UIImage.gradientImage(bounds: readyView.bounds, colors: [.gradient1, .gradient2, .gradient3])
        let gradientColor = UIColor(patternImage: gradietn)
        readyView.layer.borderColor = gradientColor.cgColor
        readyView.layer.borderWidth = 1
        
        var plusTapped = TrackerViewControllerCell()
        plusTapped.twoDelegate = self
        plusTapped.tapDelegate()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trackerRecord.isEmpty ? setupEmptyErrorViews() : setupViews()
        dayCount = "\(UserDefaults.standard.integer(forKey: "DayCount"))"
    }
    
    //Установка пустого/ошибочного экрана (заглушка)
    private func setupEmptyErrorViews() {
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            ])
    }
    //Установка экрана статистики
    private func setupViews() {
        view.addSubview(readyView)
        readyView.addSubview(dayCuntLabel)
        readyView.addSubview(endTracker)
        NSLayoutConstraint.activate([
            readyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            readyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyView.heightAnchor.constraint(equalToConstant: 90),
        
            dayCuntLabel.topAnchor.constraint(equalTo: readyView.topAnchor, constant: 12),
            dayCuntLabel.leadingAnchor.constraint(equalTo: readyView.leadingAnchor, constant: 12),
            dayCuntLabel.trailingAnchor.constraint(equalTo: readyView.trailingAnchor, constant: -12),
        
            endTracker.topAnchor.constraint(equalTo: dayCuntLabel.bottomAnchor, constant: 7),
            endTracker.leadingAnchor.constraint(equalTo: readyView.leadingAnchor, constant: 12),
            endTracker.trailingAnchor.constraint(equalTo: readyView.trailingAnchor, constant: -12)
        ])
    }
}

extension StatisticsViewController: UpdateStatisticsDaysDelegate {
    func updateDays(count: String) {
        dayCuntLabel.text = count
    }
}

