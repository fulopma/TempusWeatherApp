//
//  AcknowlegementsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/17/25.
//

import UIKit
import SwiftUI
import NewRelic

struct AcknowlegementsViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context)
    -> AcknowlegementsViewController {
        return AcknowlegementsViewController()
    }
    func updateUIViewController(_ uiViewController: AcknowlegementsViewController, context: Context) {
        // do nothing
    }
}

final class AcknowlegementsViewController: UIViewController {
    let acknowledgementsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.darkGray
        label.backgroundColor = .clear
        label.text = """
        Weather information provided by Open-Meteo. Noncommercial use only.
        https://open-meteo.com/
        DGCharts. Apache License 2.0.
        DynamicColor. MIT License.
        SwiftLint. MIT License.
        """
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        view.addSubview(acknowledgementsLabel)
        acknowledgementsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            acknowledgementsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            acknowledgementsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            acknowledgementsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            acknowledgementsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])
        self.title = "Acknowledgements"
        NewRelic.recordCustomEvent("Loaded Acknowledgements")
        NewRelic.recordBreadcrumb("Loaded Acknowledgements")
    }
}
