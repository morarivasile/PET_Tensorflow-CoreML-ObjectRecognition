//
//  ModelDataHandler.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/19/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Vision

protocol ModelDataHandler {
    func runModel(onFrame pixelBuffer: CVPixelBuffer, completion: @escaping ((Result?) -> ()))
}
