// MIT License
// Copyright (c) 2021-2023 LinearMouse

import Combine
import Foundation
import SwiftUI

class DeviceModel: ObservableObject, Identifiable {
    var id = UUID()

    let deviceRef: WeakRef<Device>

    private var subscriptions = Set<AnyCancellable>()

    @Published var isActive = false
    @Published var isSelected = false

    let name: String
    let category: Device.Category

    init(deviceRef: WeakRef<Device>) {
        self.deviceRef = deviceRef

        name = deviceRef.value?.name ?? "(removed)"
        category = deviceRef.value?.category ?? .mouse

        DeviceManager.shared.$lastActiveDeviceRef
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .map { deviceRef.value != nil && $0?.value == deviceRef.value }
            .sink { [weak self] value in
                withAnimation {
                    self?.isActive = value
                }
            }
            .store(in: &subscriptions)

        DeviceState.shared.$currentDeviceRef
            .map { deviceRef.value != nil && $0?.value == deviceRef.value }
            .assign(to: \.isSelected, on: self)
            .store(in: &subscriptions)
    }
}

extension DeviceModel {
    var isMouse: Bool { category == .mouse }
    var isTrackpad: Bool { category == .trackpad }
}
