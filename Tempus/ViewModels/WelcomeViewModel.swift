//
//  WelcomeViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import Foundation
import CoreLocation

class WelcomeViewModel: ObservableObject {
    var query: String = ""
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    var unit: Units = .usCustomary
    func findLocation() async {
        if query.isEmpty || query.contains(/s+/) {
            return
        }
        print("Searching for location...")
    }
}
