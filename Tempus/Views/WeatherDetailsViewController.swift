//
//  WeatherDetailsViewController.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import UIKit

enum WeatherDetailsScreen {
    case Temperature
    case Precipitation
    case Smog
}

class WeatherDetailsViewController: UIViewController {
    private var screen: WeatherDetailsScreen = .Temperature
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
