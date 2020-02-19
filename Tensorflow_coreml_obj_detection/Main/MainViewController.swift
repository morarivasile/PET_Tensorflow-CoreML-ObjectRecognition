//
//  ViewController.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/18/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVKit
import Vision

final class MainViewController: CameraFeedViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: Controllers that manage functionality
    private var modelDataHandler: ModelDataHandler?
    
    // MARK: Constants
    private let delayBetweenInferencesMs: Double = 200
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    
    // MARK: - IBActions
    
    @IBAction func coreMLButtonTapped(_ sender: UIButton) {
        modelDataHandler = CoreMLModelDataHandler(mlModel: YOLOv3Tiny().model)
        changeVisibility(true)
        title = "CoreML"
    }
    
    @IBAction func tensorFlowButtonTapped(_ sender: UIButton) {
        modelDataHandler = TFModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
        changeVisibility(true)
        title = "TensorFlow"
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        modelDataHandler = nil
        changeVisibility(false)
        overlayView.clear()
        title = nil
    }
    
    private func changeVisibility(_ isHidden: Bool) {
        visualEffectView.isHidden = isHidden
        closeButton.isHidden = !isHidden
    }
    
    override func didOutput(pixelBuffer: CVPixelBuffer) {
        guard let modelDataHandler = modelDataHandler else { return }
        
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        
        guard (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
            return
        }
        
        previousInferenceTimeMs = currentTimeMs
        modelDataHandler.runModel(onFrame: pixelBuffer, completion: { (result) in
            guard let result = result else { return }

            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            let imageSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            
            DispatchQueue.main.async {
                // Draws the bounding boxes and displays class names and confidence scores.
                self.overlayView.drawAfterPerformingCalculations(onInferences: result.inferences, withImageSize: imageSize)
            }
        })
    }
    
}
