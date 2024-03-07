//
//  StatisticsViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 22.12.2023.
//

import UIKit

//Статистика

class StatisticsViewController: UIViewController {
    
    let trackerRecord = TrackerRecordStore.shared.fetchAllRecord()
    
    //MARK: Empty and Error Views
    private lazy var emptyLabel: UILabel = {
       let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udBlackDay
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.red.cgColor
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        print("\(trackerRecord.count)")
        trackerRecord.isEmpty ? setupEmptyErrorViews() : setupViews()
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
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
    }
}
