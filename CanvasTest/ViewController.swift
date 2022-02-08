//
//  ViewController.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/2/7.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
           canvas.refresh()
       }
    
    @IBAction func onClear(_ sender: Any) {
        canvas.clearCanvas()
    }
    
    @IBAction func onRevert(_ sender: Any) {
        canvas.revertLast()
    }
    
    @IBAction func onSave(_ sender: Any) {
        if let img = canvas.export(){
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
    }
}
