//
//  TablewViewCell.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 04.01.2024.
//

import UIKit

//Класс таблицы
class TablewViewCell: UITableViewCell {
    let identifier = "TableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
