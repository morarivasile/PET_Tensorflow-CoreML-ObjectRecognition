//
//  MobileNetSSD.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/19/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation

/// Information about the MobileNet SSD model.
enum MobileNetSSD {
  static let modelInfo: FileInfo = (name: "detect", extension: "tflite")
  static let labelsInfo: FileInfo = (name: "labelmap", extension: "txt")
}
