//
//  CGImagePropertyOrientation+Initializers.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/20/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: fatalError("New orientation is not handled")
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portraitUpsideDown: self = .left
        case .landscapeLeft: self = .up
        case .landscapeRight: self = .down
        default: self = .right
        }
    }
}

