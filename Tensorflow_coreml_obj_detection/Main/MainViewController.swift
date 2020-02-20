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
    @IBOutlet weak var fpsLabel: UILabel!
    
    // MARK: Controllers that manage functionality
    private var modelDataHandler: ModelDataHandler?
    private let fpsCounter = FPSCounter()
    
    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        cameraFeedManager.setFrameInterval(3)
        fpsCounter.start()
    }
    
    // MARK: IBActions
    @IBAction func coreMLButtonTapped(_ sender: UIButton) {
        modelDataHandler = CoreMLModelDataHandler(mlModel: ObjectDetector().model, drawRectSize: overlayView.bounds.size)
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
    
    // MARK: Private
    private func changeVisibility(_ isHidden: Bool) {
        fpsLabel.isHidden = !isHidden
        visualEffectView.isHidden = isHidden
        closeButton.isHidden = !isHidden
    }
    
    private func updateFPSLabel() {
        DispatchQueue.main.async {
            self.fpsCounter.frameCompleted()
            self.fpsLabel.text = String(format: "%.1f FPS\nFrame interval: %d", self.fpsCounter.fps, self.cameraFeedManager.frameInterval)
        }
    }
    
    // MARK: Override
    override func didOutput(pixelBuffer: CVPixelBuffer) {
        updateFPSLabel()
        
        modelDataHandler?.runModel(onFrame: pixelBuffer, completion: { (result) in
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
