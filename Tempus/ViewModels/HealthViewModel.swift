//
//  HealthViewModel.swift
//  Tempus
//
//  Created by Marcell Fulop on 8/6/25.
//

import Foundation
import HealthKit

final class HealthViewModel: ObservableObject {
    private let healthStore: HKHealthStore = HKHealthStore()
    private let allTypes = Set([
        HKObjectType.characteristicType(forIdentifier: .fitzpatrickSkinType)
    ].compactMap({$0}))
    init() {
        do {
            if HKHealthStore.isHealthDataAvailable() {
                Task {
                    try await healthStore.requestAuthorization(toShare: [], read: allTypes)
                }
            }
            print(try healthStore.fitzpatrickSkinType().skinType.rawValue)
        } catch {
            print(error.localizedDescription)
        }
    }
}
