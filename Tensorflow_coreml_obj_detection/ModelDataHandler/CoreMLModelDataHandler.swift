//
//  CoreMLModelDataHandler.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/19/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import Vision

class CoreMLModelDataHandler: NSObject, ModelDataHandler {
    
    private let vnCoreMLModel: VNCoreMLModel
    
    private let colorStrideValue = 10
    
    private let drawRectSize: CGSize
    
    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0/255.0, green: 200.0/255.0, blue: 250.0/255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown
    ]
    
    init?(mlModel: MLModel, drawRectSize: CGSize) {
        guard let vnCoreMLModel = try? VNCoreMLModel(for: mlModel) else {
            return nil
        }
        
        self.vnCoreMLModel = vnCoreMLModel
        self.drawRectSize = drawRectSize
    }
    
    func runModel(onFrame pixelBuffer: CVPixelBuffer, completion: @escaping ((Result?) -> ())) {
        // Tell Vision about the orientation of the image.
        let orientation = exifOrientationFromDeviceOrientation()
        
        let request = VNCoreMLRequest(model: vnCoreMLModel) { (req, err) in
            completion(self.getResult(from: req, pixelBuffer: pixelBuffer))
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:]).perform([request])
    }
    
    private func getResult(from request: VNRequest, pixelBuffer: CVPixelBuffer) -> Result? {
        guard let results = request.results else { return nil }
        
        var resultArray: [Inference] = []
        
        for (index, observation) in results.enumerated() where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(width), Int(height))
            let color = colorForClass(withIndex: index + 1)
            
            var newRect = objectObservation.boundingBox.applying(CGAffineTransform(scaleX: CGFloat(width), y: CGFloat(height)))
            
            newRect.origin.y = CGFloat(height) - newRect.origin.y - newRect.height
            
            resultArray.append(Inference(confidence: topLabelObservation.confidence, className: topLabelObservation.identifier, rect: newRect, displayColor: color))
        }
        
        return Result(inferences: resultArray)
    }
    
    /// This assigns color for a particular class.
    private func colorForClass(withIndex index: Int) -> UIColor {
        // We have a set of colors and the depending upon a stride, it assigns variations to of the base
        // colors to each object based on its index.
        let baseColor = colors[index % colors.count]
        
        var colorToAssign = baseColor
        
        let percentage = CGFloat((colorStrideValue / 2 - index / colors.count) * colorStrideValue)
        
        if let modifiedColor = baseColor.getModified(byPercentage: percentage) {
            colorToAssign = modifiedColor
        }
        
        return colorToAssign
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
           let curDeviceOrientation = UIDevice.current.orientation
           let exifOrientation: CGImagePropertyOrientation
           
           switch curDeviceOrientation {
           case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
               exifOrientation = .left
           case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
               exifOrientation = .upMirrored
           case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
               exifOrientation = .down
           case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
               exifOrientation = .up
           default:
               exifOrientation = .up
           }
           return exifOrientation
       }
}
