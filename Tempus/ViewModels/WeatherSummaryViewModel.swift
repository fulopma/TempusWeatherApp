//
//  WeatherSummaryViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import Foundation

class WeatherSummaryViewModel: ObservableObject {
    private var latitude: Double = 0
    private var longitude: Double = 0
    var city: String = ""
    private let temperature = 0.0
    init(latitude: Double, longitude: Double, city: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
    }
}
