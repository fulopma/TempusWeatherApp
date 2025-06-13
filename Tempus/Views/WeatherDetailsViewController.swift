//
//  WeatherDetailsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import UIKit
import SwiftUI

enum WeatherDetailsScreen {
    case Temperature
    case Precipitation
    case Smog
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
        // put something in here or something 
    }
}

class WeatherDetailsViewController: UIViewController {
    private var screen: WeatherDetailsScreen = .Temperature
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    

}
