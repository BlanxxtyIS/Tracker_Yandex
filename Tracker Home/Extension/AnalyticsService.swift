//
//  AnaliticaEnums.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 11.03.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "58e1b21f-0f1a-458c-9164-6aa0fb3e0b68") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, parameters : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
