//  CaptureOrientation.swift
//
//
//  Created by Spencer Whyte on 2023-05-28.
//

import Foundation
import AVFoundation
import CoreMotion

class CaptureOrientation {

    private(set) var current = AVCaptureVideoOrientation.portrait

    private let motionManager = CMMotionManager()

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            self?.updateOrientation(data: data)
        }
    }

    private func updateOrientation(data: CMAccelerometerData?) {
        if let data = data {
            current = data.orientation ?? current
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}

private extension CMAccelerometerData {

    var orientation: AVCaptureVideoOrientation? {
        if acceleration.z < -0.75 || acceleration.z > 0.75 {
            return nil
        }

        let denominator = abs(acceleration.x) + abs(acceleration.y)
        guard denominator != 0 else {
            return nil
        }
        let scale = 1.0 / denominator

        let x = acceleration.x * scale
        let y = acceleration.y * scale
        if x < -0.5 {
            return .landscapeRight
        }
        if x > 0.5 {
            return .landscapeLeft
        }
        if y < -0.5 {
            return .portrait
        }
        if y > 0.5 {
            return .portraitUpsideDown
        }
        return nil
    }
}
