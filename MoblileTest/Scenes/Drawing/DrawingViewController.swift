//
//  DrawingViewController.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 14/5/24.
//

import Foundation
import UIKit
import Reusable

class DrawingViewController: UIViewController {
    @IBOutlet var drawingView: DrawableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func handleUndoButton(_ sender: UIButton) {
        drawingView.undo()
    }
    
    @IBAction func handleSwitchButton(_ sender: UISegmentedControl) {
        let mode: DrawableView.DrawingMode = sender.selectedSegmentIndex == 0 ? .draw : .erase
        drawingView.set(mode: mode)
    }
    
    @IBAction func handleStickerButton(_ sender: UIButton) {
        drawingView.addSticker()
    }
    
    @IBAction func handleSaveButton(_ sender: UIButton) {
        let selector = #selector(self.onImageSaved(_:error:contextInfo:))
            drawingView.takeSnapshot()?.saveToPhotoLibrary(self, selector)
    }
    
    @objc private func onImageSaved(_ image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", 
                                       message: error.localizedDescription,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", 
                                       message: "Your altered image has been saved to your photos.",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }

}

extension DrawingViewController: StoryboardSceneBased {
    static var sceneStoryboard: UIStoryboard = UIStoryboard(name: "Drawing", bundle: nil)
}

extension UIView {

    func takeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: self.frame.size.width, height: self.frame.size.height - 5))
        let rect = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {

    func saveToPhotoLibrary(_ completionTarget: Any?, _ completionSelector: Selector?) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIImageWriteToSavedPhotosAlbum(self, completionTarget, completionSelector, nil)
        }
    }
}
