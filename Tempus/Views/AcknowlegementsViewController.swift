//
//  AcknowlegementsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/17/25.
//

import UIKit
import SwiftUI

struct AcknowlegementsViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context)
    -> AcknowlegementsViewController {
        return AcknowlegementsViewController()
    }
    func updateUIViewController(_ uiViewController: AcknowlegementsViewController, context: Context) {
        // do nothing
    }
}

class AcknowlegementsViewController: UIViewController {
    
    let acknowledgementsLabel = {
        let ackowledgementsLabel = UILabel()
        ackowledgementsLabel.numberOfLines = 0
        ackowledgementsLabel.textAlignment = .center
        ackowledgementsLabel.text =
        """
            Weather information provided by Open-Meteo. Noncommercial use only.
            <a href="https://open-meteo.com/">Weather data by Open-Meteo.com</a>
            DGCharts. Apache License 2.0.
            DynamicColor. MIT License. 
            SwiftLint. MIT License.
        """
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
