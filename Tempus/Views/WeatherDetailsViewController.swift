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
    var viewModel: WeatherDetailsViewModel
    func makeUIViewController(context: Context)
    -> WeatherDetailsViewController {
        let weatherDetailsViewController = WeatherDetailsViewController(
            viewModel: viewModel
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

class YearAxisValueFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value))
    }
}

class WeatherDetailsViewController: UIViewController, ChartViewDelegate {
    @Published private var screen: WeatherDetailsScreen = .temperature
    @ObservedObject private var viewModel: WeatherDetailsViewModel
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
        // Add swipe gesture recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        viewModel.$isDone.sink { [weak self] isDoneLoading in
            if isDoneLoading {
                print("Chart printed \(isDoneLoading)")
                self?.setupChartView()
                self?.setChartData()
            }
        }.store(in: &subscriptions)
        subscriptions.insert($screen.sink(receiveValue: { [weak self] screen in
            self?.setChartData() // update chart on screen change
            switch screen {
            case .temperature:
                self?.label.text = "Temperature\nSwipe up to see precipitation"
            case .precipitation:
                self?.label.text = "Precipitation\nSwipe down to see temperature; swipe up to see smog"
            case .smog:
                self?.label.text = "Smog (PM10)\nSwipe down to see precipitation"
            }
        }))
    }
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            switch screen {
            case .temperature:
                screen = .precipitation
            case .precipitation:
                screen = .smog
            case .smog:
                break // already at last
            }
        case .down:
            switch screen {
            case .smog:
                screen = .precipitation
            case .precipitation:
                screen = .temperature
            case .temperature:
                break // already at first
            }
        default:
            break
        }
    }
    deinit {
        // cancel all subscriptions
        subscriptions.forEach({$0.cancel()})
        print("Subscriptions canceled")
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
        // Set custom x-axis formatter to remove commas from years
        scatterChartView.xAxis.valueFormatter = YearAxisValueFormatter()
    }
    private func setChartData() {
        let scv: ScatterChartDataSet?
        switch screen {
        case .temperature:
            scv = ScatterChartDataSet(
               entries: viewModel.getTemperatureChartEntries(),
               label: "Temperature v. Time"
           )
        case .precipitation:
            scv = ScatterChartDataSet(entries: viewModel.getPrecipitationChartEntries(), label: "Precipitation v. Time")
        case .smog:
            scv = ScatterChartDataSet(entries: viewModel.getSmogChartEntries(), label: "PM10 v. Time")
        }
        guard let scv = scv else {
            print("Failed to generate ScatterChartDataSet")
            return
        }
        scv.colors = [.blue]
        scv.scatterShapeSize = 10
        let data = ScatterChartData(dataSet: scv)
        scatterChartView.data = data
        print("scatter chart pushed to view controller")
    }
}
