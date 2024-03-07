//
//  TrackerViewControllerCell.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 26.12.2023.
//

import UIKit

protocol TrackerViewControllerCellDelegate: AnyObject {
    func completeTracker(id: UUID, indexPath: IndexPath)
    func uncompleteTracker(id: UUID, indexPath: IndexPath)
    func toFix(id: UUID)
    func toEdit(id: UUID, dayLabel: String)
    func toRemove(id: UUID)
}

//Ячейки коллекции
class TrackerViewControllerCell: UICollectionViewCell {
        
    weak var delegate: TrackerViewControllerCellDelegate?
    
    let trackerStore = TrackerStore.shared
    
    let currentDate = Date()
    var selectedDate = Date()
    
    var activeButton: Bool = true
    
    var trackerId: UUID?
    var indexPath: IndexPath?
    
    let identifier: String = "trackerCell"
    
    var completeCell = false
    
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
        button.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAllViews()
        
        let contextMenu = UIContextMenuInteraction(delegate: self)
        colorView.addInteraction(contextMenu)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func completionCountDaysText(completedDays: Int){
        let remainder = completedDays % 100
        if (11...14).contains(remainder) {
            dayLabel.text = "\(completedDays) дней"
        } else {
            switch remainder % 10 {
            case 1:
                dayLabel.text = "\(completedDays) день"
            case 2...4:
                dayLabel.text = "\(completedDays) дня"
            default:
                dayLabel.text = "\(completedDays) дней"
            }
        }
    }

    @objc private func plusButtonClicked() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("Не найден айди или индекс")
            return
        }
        if completeCell {
            delegate?.uncompleteTracker(id: trackerId, indexPath: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, indexPath: indexPath)
        }
    }
    
    func setupData(traker: Tracker, dayCount: Int, isCompletedToday: Bool, indexPath: IndexPath) {
        colorView.backgroundColor = traker.color
        plusButton.backgroundColor = traker.color
        emoji.text = traker.emoji
        textLabel.text = traker.name
        completionCountDaysText(completedDays: dayCount)
        
        self.completeCell = isCompletedToday
        
        self.trackerId = traker.id
        self.indexPath = indexPath
        
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        let imageView = UIImageView(image: image)
        plusButton.backgroundColor = isCompletedToday ? traker.color.withAlphaComponent(0.3) : traker.color
        plusButton.setImage(image, for: .normal)
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

//MARK: - Контекстное меню
extension TrackerViewControllerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let trackerId = trackerId else {
            assertionFailure("Не найден айди или индекс")
            return nil
        }
        let boolean = trackerStore.fetchTracker(withID: trackerId)?.isPinned
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
        return UIMenu(children: [
            UIAction(title: !boolean! ? "Закрепить" : "Открепить") { [weak self] _ in
                if let indexPath = self?.indexPath {
                    self?.toFixed()
                }},
            UIAction(title: "Редактировать") { [weak self] _ in
                if let indexPath = self?.indexPath {
                    self?.toEdited()
                }},
            UIAction(title: "Удалить", attributes: [.destructive]) { [weak self] _ in
                if let indexPath = self?.indexPath {
                    self?.toRemoved()
                }},
        ])}
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
        return configuration
    }
    
    private func toFixed() {
        guard let trackerId = trackerId else {
            assertionFailure("Не найден айди или индекс")
            return
        }
        delegate?.toFix(id: trackerId)
        print("Закрепить")
    }
    
    private func toEdited() {
        guard let trackerId = trackerId else {
            assertionFailure("Не найден айди или индекс")
            return
        }
        let days = dayLabel.text!
        delegate?.toEdit(id: trackerId, dayLabel: days)
        print("Изменить")
    }
    
    private func toRemoved() {
        guard let trackerId = trackerId else {
            assertionFailure("Не найден айди или индекс")
            return
        }
        delegate?.toRemove(id: trackerId)
        print("Удалить")
    }
}
