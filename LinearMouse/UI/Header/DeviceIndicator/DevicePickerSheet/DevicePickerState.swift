// MIT License
// Copyright (c) 2021-2023 LinearMouse

import Combine
import SwiftUI

class DevicePickerState: ObservableObject {
    static let shared = DevicePickerState()

    var subscriptions = Set<AnyCancellable>()

    @Published var devices: [DeviceModel] = []

    init() {
        DeviceManager.shared.$devices.map {
            $0
                .map { DeviceModel(deviceRef: WeakRef($0)) }
        }
        .receive(on: RunLoop.main)
        .sink { [weak self] value in
            withAnimation {
                self?.devices = value
            }
        }
        .store(in: &subscriptions)
    }
}
