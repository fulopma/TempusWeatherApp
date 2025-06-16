//
//  WeatherDetailsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import DGCharts
import SwiftUI
import UIKit
import Combine

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
    func makeUIViewController(context: Context)
    -> WeatherDetailsViewController {
        guard let wdViewModel = viewModel else {
            fatalError("viewModel is null")
        }
        let weatherDetailsViewController = WeatherDetailsViewController(
            viewModel: wdViewModel
        )
        return weatherDetailsViewController
    }
    func updateUIViewController(
        _ uiViewController: WeatherDetailsViewController,
        context: Context
    ) {
        // literally do nothing for right now
    }
}

class WeatherDetailsViewController: UIViewController, ChartViewDelegate {
    private var screen: WeatherDetailsScreen = .temperature
    private let viewModel: WeatherDetailsViewModel
    private let scatterChartView: ScatterChartView = ScatterChartView()
    private var subscription: AnyCancellable?
    init(viewModel: WeatherDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.city
        subscription = viewModel.$isDone.sink { [weak self] isDoneLoading in
            if isDoneLoading {
                print("Chart printed \(isDoneLoading)")
                self?.setupChartView()
                self?.setChartData()
            }
        }
    }
    deinit {
        subscription?.cancel()
        print("Subscribption canceled")
    }
    override func viewDidAppear(_ animated: Bool) {
      //  print(viewModel.temperatureData.map({ $0.1 }))
    }
    private func setupChartView() {
        scatterChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scatterChartView)
        NSLayoutConstraint.activate([
            scatterChartView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scatterChartView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scatterChartView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            scatterChartView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
    private func setChartData() {
        let scv = ScatterChartDataSet(
            entries: viewModel.getTemperatureChartEntries(),
            label: "Temperature v. Time"
        )
        scv.colors = [.blue]
        scv.scatterShapeSize = 10

        let data = ScatterChartData(dataSet: scv)
        scatterChartView.data = data
    }
}
