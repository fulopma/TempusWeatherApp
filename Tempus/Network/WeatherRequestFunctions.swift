//
//  WeatherRequestFunctions.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/16/25.
//
/// I want to just use a triple tuple but swift lint complained, so I created a simple struct
struct CurrentWeatherResponse {
    var currentTemp: Double
    var lastWeekPrecip: Double
    var currentSmog: Double
    init() {
        self.currentSmog = -1
        self.currentTemp = -1
        self.lastWeekPrecip = -1
    }
}
