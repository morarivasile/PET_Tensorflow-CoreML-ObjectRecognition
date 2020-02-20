//
//  FPSCounter.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/18/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation
import QuartzCore

class FPSCounter {
    private(set) public var fps: Double = 0
    
    var frames = 0
    var startTime: CFTimeInterval = 0
    
    func start() {
        frames = 0
        startTime = CACurrentMediaTime()
    }
    
    func frameCompleted() {
        frames += 1
        let now = CACurrentMediaTime()
        let elapsed = now - startTime
        if elapsed >= 0.01 {
            fps = Double(frames) / elapsed
            if elapsed >= 1 {
                frames = 0
                startTime = now
            }
        }
    }
}

