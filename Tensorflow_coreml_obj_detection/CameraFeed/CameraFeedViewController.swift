//
//  CameraFeedViewController.swift
//  Tensorflow_coreml_obj_detection
//
//  Created by Vasile Morari on 2/19/20.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

class CameraFeedViewController: UIViewController {
    
    // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    
    // MARK: Controllers that manage functionality
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    
    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraFeedManager.delegate = self
        overlayView.clearsContextBeforeDrawing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedManager.stopSession()
    }
    
    // MARK: Button Actions
    @IBAction func onClickResumeButton(_ sender: Any) {
        cameraFeedManager.resumeInterruptedSession { (complete) in
            
            if complete {
                self.resumeButton.isHidden = true
                self.cameraUnavailableLabel.isHidden = true
            }
            else {
                self.presentUnableToResumeSessionAlert()
            }
        }
    }
    
    func presentUnableToResumeSessionAlert() {
        let alert = UIAlertController(
            title: "Unable to Resume Session",
            message: "There was an error while attempting to resume session.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}

// MARK: CameraFeedManagerDelegate
extension CameraFeedViewController: CameraFeedManagerDelegate {
    @objc func didOutput(pixelBuffer: CVPixelBuffer) {
        // Oberride in sublasses to handle changes
    }
    
    // MARK: Session Handling Alerts
    func sessionRunTimeErrorOccured() {
        // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
        resumeButton.isHidden = false
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        // Updates the UI when session is interupted.
        if resumeManually {
            resumeButton.isHidden = false
        }
        else {
            cameraUnavailableLabel.isHidden = false
        }
    }
    
    func sessionInterruptionEnded() {
        // Updates UI once session interruption has ended.
        if !cameraUnavailableLabel.isHidden {
            cameraUnavailableLabel.isHidden = true
        }
        
        if !resumeButton.isHidden {
            resumeButton.isHidden = true
        }
    }
}
