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
    @Published private var screen: WeatherDetailsScreen = .temperature
    private let viewModel: WeatherDetailsViewModel
    private let scatterChartView: ScatterChartView = ScatterChartView()
    private var subscriptions: Set<AnyCancellable> = []
    private lazy var label: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
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
        subscriptions.insert( viewModel.$isDone.sink { [weak self] isDoneLoading in
            if isDoneLoading {
                print("Chart printed \(isDoneLoading)")
                self?.setupChartView()
                self?.setChartData()
            }
        })
        subscriptions.insert($screen.sink(receiveValue: { [weak self] screen in
            switch screen {
            case .temperature:
                self?.label.text = "Temperature"
            case .precipitation:
                self?.label.text = "Precipitation"
            case .smog:
                self?.label.text = "Smog (PM10)"
            }
        }))
    }
    deinit {
        // cancel all subscriptions
        subscriptions.forEach({$0.cancel()})
        print("Subscriptions canceled")
    }
    override func viewDidAppear(_ animated: Bool) {
      //  print(viewModel.temperatureData.map({ $0.1 }))
    }
    private func setupChartView() {
        scatterChartView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scatterChartView)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            scatterChartView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scatterChartView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scatterChartView.topAnchor.constraint(
                equalTo: label.bottomAnchor, constant: 10
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
        print("scatter chart pushed to view controller")
    }
}
