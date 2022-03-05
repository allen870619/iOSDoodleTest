//
//  ViewController.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/2/7.
//  Behavioral Patterns: Command, Memento, Chain of Responsibility

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var btnStack: UIStackView!
    
    // data
    let btnControl = ["Revert", "Clear", "Export", "SnapShot", "Load", "CheckSnapShot"]
    var snapShotList = [PaintData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // btn action init with command pattern
        for usage in btnControl{
            let btn = UIButton()
            btn.setTitle(usage, for: .normal)
            btn.setTitleColor(.blue, for: .normal)
            btn.addAction(UIAction(){[weak self] _ in
                self?.canvasAction(btn, command: usage)
            }, for: .touchUpInside)
            btnStack.addArrangedSubview(btn)
        }
        setupHandler()
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
        case "export":
            if let img = canvas.export(){
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                showAlertHint()
            }
        case "snapshot": // memento: save
            snapShotList.append(canvas.getPaintData())
            if snapShotList.count > 5{
                snapShotList.removeFirst()
            }
            showAlertHint()
            break
        case "load": // memento: load
            let picker = UIAlertController(title: "Snapshot", message: nil, preferredStyle: .actionSheet)
            for (i, shot) in snapShotList.enumerated(){
                let alert = UIAlertAction(title: "snapshot \(i+1)", style: .default){[weak self] _ in
                    self?.canvas.loadSnapShot(shot)
                }
                picker.addAction(alert)
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            picker.addAction(cancel)
            
            picker.popoverPresentationController?.sourceView = btn
            present(picker, animated: true, completion: nil)
            break
        case "checksnapshot":
            // origin
            if checkSnapEmpty.handler(request: checkSnapEmpty.request){
                showAlertHint(title: "Accept")
            }else{
                showAlertHint(title: "Not Good")
            }
            
            // direct
            //            if dCheckSnapEmpty.handle(){
            //                showAlertHint(title: "Accept")
            //            }else{
            //                showAlertHint(title: "Not Good")
            //            }
        default:
            break
        }
    }
    
    private func showAlertHint(title: String = "Success!"){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true){
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.5)){
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// This is for Chain of Responsibility Practice
    let checkSnapEmpty = CheckSnapEmpty()
    let checkRevertAvl = CheckCanRevert()
    
    let dCheckSnapEmpty = DirectHandler()
    let dCheckRevertAvl = DirectHandler()
    private func setupHandler(){
        // origin
        checkSnapEmpty.request = {
            return !self.snapShotList.isEmpty
        }
        
        checkRevertAvl.request = {
            for i in self.snapShotList{
                if i.strokeList.isEmpty{
                    return false
                }
            }
            return true
        }
        checkSnapEmpty.nextHandler = checkRevertAvl
        
        // direct
        dCheckSnapEmpty.request = {
            return !self.snapShotList.isEmpty
        }
        
        dCheckRevertAvl.request = {
            for i in self.snapShotList{
                if i.strokeList.isEmpty{
                    return false
                }
            }
            return true
        }
        dCheckSnapEmpty.nextHandler = dCheckRevertAvl
    }
}

/// This is for Chain of Responsibility Practice
// direct to use
protocol ResHandler{
    var request: ()->Bool {get set}
    var nextHandler: ResHandler? {get set}
    
    func handle()-> Bool
}

class DirectHandler: ResHandler{
    var request: () -> Bool = { true }
    
    var nextHandler: ResHandler?
    
    func handle() -> Bool {
        if request(){
            print("\(self) Passed")
            return nextHandler?.handle() ?? true
        }else{
            print("\(self) Failed")
            return false
        }
    }
}

// original
class BaseHandlerO{
    var request: (()->Bool) = { true }
    var nextHandler: BaseHandlerO?
    
    func handler(request: (()->Bool)) -> Bool{
        if request(){
            if let nextHandler = nextHandler {
                return nextHandler.handler(request: nextHandler.request)
            }
            return true
        }else{
            return false
        }
    }
}

class CheckSnapEmpty: BaseHandlerO{
    override func handler(request: (() -> Bool)) -> Bool {
        print("Check snapshot isEmpty")
        print("pass: \(request())")
        return super.handler(request: request)
    }
}

class CheckCanRevert: BaseHandlerO{
    override func handler(request: (() -> Bool)) -> Bool {
        print("Check can revert")
        print("pass: \(request())")
        return super.handler(request: request)
    }
}
