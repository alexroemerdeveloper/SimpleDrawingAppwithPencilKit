//
//  ViewController.swift
//  SimpleDrawingAppwithPencilKit
//
//  Created by Alexander Römer on 14.06.20.
//  Copyright © 2020 Alexander Römer. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvas: PKCanvasView!
    
    private let canvasWidth: CGFloat            = 768
    private let canvasOverscrollHeight: CGFloat = 500
    private var drawing: PKDrawing              = PKDrawing()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasScaleSetup()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    fileprivate func canvasScaleSetup() {
        let canvasScale = canvas.bounds.width / canvasWidth
        canvas.minimumZoomScale = canvasScale
        canvas.maximumZoomScale = canvasScale
        canvas.zoomScale        = canvasScale
        updateContentSizeForDrawing()
        canvas.contentOffset    = CGPoint(x: 0, y: -canvas.adjustedContentInset.top)
    }
        
    fileprivate func setupCanvas() {
        canvas.delegate = self
        canvas.drawing  = drawing
        canvas.alwaysBounceVertical = true
        canvas.allowsFingerDrawing  = true
        
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
    }
    
    
    private func updateContentSizeForDrawing() {
        let drawing = canvas.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvas.bounds.height, ((drawing.bounds.maxY + self.canvasOverscrollHeight) * canvas.zoomScale))
        } else {
            contentHeight = canvas.bounds.height
        }
        
        canvas.contentSize = CGSize(width: canvasWidth * canvas.zoomScale, height: contentHeight)
    }
    
    
    @IBAction func toggleDrawingType(_ sender: UIBarButtonItem) {
        canvas.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvas.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    @IBAction func saveToCamera(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvas.bounds.size, false, UIScreen.main.scale)
        canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: true)
        
        guard let uiImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
        }) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }

}


extension ViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
}

extension ViewController: PKToolPickerObserver {}
