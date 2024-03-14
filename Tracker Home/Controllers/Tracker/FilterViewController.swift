//
//  FilterViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 07.03.2024.
//

import UIKit

protocol FilterViewControllerProtocol: AnyObject {
    func filterSetting(_ setting: Int)
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerProtocol?
    init(delegate: FilterViewControllerProtocol?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let filtred: [String] = [localizedText(text: "allTrackers"), localizedText(text: "trackersToday"), localizedText(text: "closed"), localizedText(text: "notClosed")]
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .udDayAndNight
        title = localizedText(text: "filters")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        UserDefaults.standard.setValue(true, forKey: "\(indexPath.row)")
        cell.accessoryType = .checkmark
        delegate?.filterSetting(indexPath.row)
        dismiss(animated: true)
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtred.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        print(indexPath.row, filtred[indexPath.row])
        cell.textLabel?.text = filtred[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .udBagroundWAD
        if UserDefaults.standard.bool(forKey: "\(indexPath.row)") {
            cell.accessoryType = .checkmark
            UserDefaults.standard.setValue(false, forKey: "\(indexPath.row)")
        }
        print(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
