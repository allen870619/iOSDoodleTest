//
//  ViewController.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/2/7.
//  Command/ Memento/

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var btnStack: UIStackView!
    let btnUsage = ["Revert", "Clear", "Save", "SnapShot", "TmpSave"]
    var snapShotList = [[PathData]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // btn action init with command pattern
        for usage in btnUsage{
            let btn = UIButton()
            btn.setTitle(usage, for: .normal)
            btn.setTitleColor(.blue, for: .normal)
            btn.addAction(UIAction(){[weak self] _ in
                self?.canvasAction(btn, command: usage)
            }, for: .touchUpInside)
            btnStack.addArrangedSubview(btn)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        canvas.refresh()
    }
    
    private func canvasAction(_ btn: UIButton, command: String){
        switch command.lowercased(){
        case "clear":
            canvas.clearCanvas()
        case "revert":
            canvas.revertLast()
        case "save":
            if let img = canvas.export(){
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                showAlertHint()
            }
        case "snapshot": // memento: save
            snapShotList.append(canvas.exportPathData())
            if snapShotList.count > 5{
                snapShotList.removeFirst()
            }
            showAlertHint()
            break
        case "tmpsave": // memento: load
            let picker = UIAlertController(title: "Snapshot", message: nil, preferredStyle: .actionSheet)
            for (i, shot) in snapShotList.enumerated(){
                let alert = UIAlertAction(title: "snapshot \(i+1)", style: .default){[weak self] _ in
                    self?.canvas.setSnapShot(shot)
                }
                picker.addAction(alert)
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            picker.addAction(cancel)
            
            picker.popoverPresentationController?.sourceView = btn
            present(picker, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    private func showAlertHint(){
        let alert = UIAlertController(title: "Success!", message: nil, preferredStyle: .alert)
        present(alert, animated: true){
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(1)){
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
