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
    private let introLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.7)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 6
        return label
    }()
    private let varianceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.systemIndigo
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.08
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        return label
    }()
    private let chartContainer: UIView = {
        let chartContainer = UIView()
        chartContainer.backgroundColor = .white
        chartContainer.layer.cornerRadius = 24
        chartContainer.layer.shadowColor = UIColor.black.cgColor
        chartContainer.layer.shadowOpacity = 0.08
        chartContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        chartContainer.layer.shadowRadius = 16
        return chartContainer
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
        setupGradientBackground()
        // Add swipe gesture recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        viewModel.$isDone.sink { [weak self] isDoneLoading in
            if isDoneLoading {
                self?.updateVarianceLabel()
                self?.setupChartView()
                self?.setChartData()
                self?.updateVarianceLabel()
            }
        }.store(in: &subscriptions)
        subscriptions.insert($screen.sink(receiveValue: { [weak self] screen in
            self?.setChartData() // update chart on screen change
            self?.updateVarianceLabel()
            switch screen {
            case .temperature:
                self?.introLabel.text = "🌡️ Temperature\nSwipe up to see precipitation"
            case .precipitation:
                self?.introLabel.text = "🌧️ Precipitation\nSwipe down to see temperature; swipe up to see smog"
            case .smog:
                self?.introLabel.text = "🌫️ Smog (PM10)\nSwipe down to see precipitation"
            }
        }))
    }
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemIndigo.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.7).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.6).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        gradient.zPosition = -1
        view.layer.insertSublayer(gradient, at: 0)
    }
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            switch screen {
            case .temperature:
                screen = .precipitation
                setChartData()
                updateVarianceLabel()
            case .precipitation:
                screen = .smog
                setChartData()
                updateVarianceLabel()
            case .smog:
                break // already at last
            }
        case .down:
            switch screen {
            case .smog:
                screen = .precipitation
                setChartData()
                updateVarianceLabel()
            case .precipitation:
                screen = .temperature
                setChartData()
                updateVarianceLabel()
            case .temperature:
                break // already at first
            }
        default:
            break
        }
    }
    deinit {
        subscriptions.forEach({$0.cancel()})
    }
    private func setupChartView() {
        // Remove previous subviews if any
        chartContainer.subviews.forEach { $0.removeFromSuperview() }
        view.subviews.forEach { if $0 == chartContainer { $0.removeFromSuperview() } }
        view.subviews.forEach { if $0 == introLabel { $0.removeFromSuperview() } }
        view.subviews.forEach { if $0 == varianceLabel { $0.removeFromSuperview() } }
        scatterChartView.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        introLabel.translatesAutoresizingMaskIntoConstraints = false
        varianceLabel.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(scatterChartView)
        view.addSubview(chartContainer)
        view.addSubview(introLabel)
        view.addSubview(varianceLabel)
        NSLayoutConstraint.activate([
            introLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            introLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            introLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            introLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            varianceLabel.topAnchor.constraint(equalTo: introLabel.bottomAnchor, constant: 12),
            varianceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            varianceLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            varianceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            chartContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartContainer.topAnchor.constraint(equalTo: varianceLabel.bottomAnchor, constant: 18),
            chartContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            scatterChartView.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: 12),
            scatterChartView.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor, constant: -12),
            scatterChartView.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 12),
            scatterChartView.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -12)
        ])
        // Chart appearance
        scatterChartView.xAxis.valueFormatter = YearAxisValueFormatter()
        scatterChartView.xAxis.labelFont = .systemFont(ofSize: 16, weight: .medium)
        scatterChartView.leftAxis.labelFont = .systemFont(ofSize: 16, weight: .medium)
        scatterChartView.xAxis.labelTextColor = .systemIndigo
        scatterChartView.leftAxis.labelTextColor = .systemTeal
        scatterChartView.rightAxis.enabled = false
        scatterChartView.xAxis.drawGridLinesEnabled = false
        scatterChartView.leftAxis.gridColor = UIColor.systemGray4
        scatterChartView.leftAxis.gridLineDashLengths = [4, 4]
        scatterChartView.legend.font = .systemFont(ofSize: 15, weight: .semibold)
        scatterChartView.legend.textColor = .systemIndigo
        scatterChartView.backgroundColor = .clear
        scatterChartView.layer.cornerRadius = 20
        scatterChartView.layer.masksToBounds = true
        scatterChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        // Make chart physically static
        scatterChartView.pinchZoomEnabled = false
        scatterChartView.doubleTapToZoomEnabled = false
        scatterChartView.dragEnabled = false
        scatterChartView.setScaleEnabled(false)
        scatterChartView.highlightPerTapEnabled = false
        scatterChartView.highlightPerDragEnabled = false
        // Tilt x-axis labels at 45 degrees
        scatterChartView.xAxis.labelRotationAngle = 45
    }
    private func updateVarianceLabel() {
        switch screen {
        case .temperature:
            if let current = viewModel.temperatureData.first?.1 {
                let typical = viewModel.typicalTemperature
                let diff = viewModel.units.convertTemperature(fromValue: current) -
                    viewModel.units.convertTemperature(fromValue: typical)
                let sign = diff > 0 ? "+" : ""
                varianceLabel.text = "Current temperature is \(sign)\(String(format: "%.1f", diff)) "
                + " \(viewModel.units.getTemperatureUnit()) compared to typical (1950s)"
            } else {
                varianceLabel.text = ""
            }
        case .precipitation:
            if let current = viewModel.precipitationData.first?.1 {
                let typical = viewModel.typicalPrecipitation
                let diff = viewModel.units.convertPrecipitation(fromValue: current) -
                    viewModel.units.convertPrecipitation(fromValue: typical)
                let sign = diff > 0 ? "+" : ""
                varianceLabel.text = "Current precipitation is \(sign)\(String(format: "%.1f", diff))" +
                    " \(viewModel.units.getPrecipationUnit()) compared to typical (1950s)"
            } else {
                varianceLabel.text = ""
            }
        case .smog:
            varianceLabel.text = ""
        }
    }
    private func setChartData() {
        let scv: ScatterChartDataSet?
        let color: UIColor
        let shape: ScatterChartDataSet.Shape
        switch screen {
        case .temperature:
            scv = ScatterChartDataSet(
               entries: viewModel.getTemperatureChartEntries(),
               label: "Temperature (\(viewModel.units.getTemperatureUnit())) v. Time"
           )
            color = .systemRed
            shape = .circle
        case .precipitation:
            scv = ScatterChartDataSet(
                entries: viewModel.getPrecipitationChartEntries(),
                label: "Precipitation (\(viewModel.units.getPrecipationUnit())) v. Time"
            )
            color = .systemBlue
            shape = .square
        case .smog:
            scv = ScatterChartDataSet(entries: viewModel.getSmogChartEntries(),
                label: "PM10 (µg/m³) v. Time")
            color = .systemOrange
            shape = .triangle
        }
        guard let scv = scv else {
            print("Failed to generate ScatterChartDataSet")
            return
        }
        scv.colors = [color]
        scv.scatterShapeSize = 14
        scv.setScatterShape(shape)
        scv.valueFont = .systemFont(ofSize: 13, weight: .medium)
        scv.valueTextColor = UIColor.systemGray
        scv.drawValuesEnabled = false
        let data = ScatterChartData(dataSet: scv)
        scatterChartView.data = data
    }
}
