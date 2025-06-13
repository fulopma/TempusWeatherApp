//
//  WeatherDetailsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import UIKit
import SwiftUI
import DGCharts

enum WeatherDetailsScreen {
    case temperature
    case precipitation
    case smog
}

struct WeatherDetailsViewControllerWrapper: UIViewControllerRepresentable {
    weak var viewModel: WeatherDetailsViewModel?
    init(viewModel: WeatherDetailsViewModel) {
        self.viewModel = viewModel
    }
    func makeUIViewController(context: Context) -> WeatherDetailsViewController {
        return WeatherDetailsViewController()
    }
    func updateUIViewController(_ uiViewController: WeatherDetailsViewController, context: Context) {
        uiViewController.viewModel = viewModel
        print("Updating viewModel")
    }
}

class WeatherDetailsViewController: UIViewController {
    private var screen: WeatherDetailsScreen = .temperature
    weak var viewModel: WeatherDetailsViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
    }
    override func viewDidAppear(_ animated: Bool) {
        print(viewModel?.temperatureData.map({$0.1}) ?? "no view model")
    }
}
