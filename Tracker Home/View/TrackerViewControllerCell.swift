//
//  TrackerViewControllerCell.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 26.12.2023.
//

import UIKit

class TrackerViewControllerCell: UICollectionViewCell {
    
    let identifier: String = "trackerCell"
    
    var isCompleteToday = false
    
    private lazy var trackerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emoji: UILabel = {
       let emoji = UILabel()
        emoji.text = "😂️️️️️️"
        emoji.numberOfLines = 1
        emoji.textAlignment = .center
        emoji.font = .systemFont(ofSize: 12, weight: .medium)
        emoji.backgroundColor = .udBackground
        emoji.layer.masksToBounds = true
        emoji.layer.cornerRadius = 12
        emoji.translatesAutoresizingMaskIntoConstraints = false
        return emoji
    }()
    
    let textLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udWhiteDay
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .udBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.tintColor = .udWhiteDay
        button.setImage(UIImage(systemName: "plus")!, for: .normal)
        button.addTarget(self, action: #selector(testPlsButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAllViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func testPlsButton() {
        if isCompleteToday {
            isCompleteToday = false
        } else {
            isCompleteToday = true
        }
        print("TEEEST")
    }
    
    func setupData(traker: Tracker, dayCount: String) {
        colorView.backgroundColor = traker.color
        plusButton.backgroundColor = traker.color
        emoji.text = traker.emoji
        textLabel.text = traker.name
        dayLabel.text = dayCount
        
        let image = isCompleteToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        plusButton.setImage(image, for: .normal)
        
        //ДЕЛЕГАТ ДОБАВИТЬ ЧТОБЫ ОБНОВЛЯЛСЯ и БЭКРАУНД ТОЖЕ ЗАМЕНА
    }
    
    private func setupAllViews() {
        contentView.addSubview(trackerView)
        trackerView.addSubview(colorView)
        colorView.addSubview(emoji)
        colorView.addSubview(textLabel)
        trackerView.addSubview(dayLabel)
        trackerView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            trackerView.heightAnchor.constraint(equalToConstant: 148),
            trackerView.widthAnchor.constraint(equalToConstant: 167),
            
            colorView.topAnchor.constraint(equalTo: trackerView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emoji.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -131),
            emoji.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -54),
            
            textLabel.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            textLabel.heightAnchor.constraint(equalToConstant: 143),
            
            dayLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            dayLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            dayLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -24),
            
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12)
        ])
    }
}
