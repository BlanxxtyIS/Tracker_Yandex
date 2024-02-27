//
//  Colors.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 27.02.2024.
//

import UIKit

final class Colors {
    func themedColor(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return darkColor
                } else {
                    return lightColor
                }
            }
        } else {
            return lightColor
        }
    }
}
