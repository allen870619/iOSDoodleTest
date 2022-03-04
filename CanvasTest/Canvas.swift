//
//  Canvas.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/2/7.
//
import UIKit

class Canvas: UIView{
    // draw style
    var strokeWidth: CGFloat = 4
    var strokeColor: UIColor = .black
    
    // data
    private var pathData = [PathData]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // draw path context
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        pathData.forEach { (pathData) in
            for (i, path) in (pathData.path.enumerated()){
                if i != 0{
                    context.addLine(to: path)
                    
                    // line style
                    if pathData.type == .pencil{
                        context.setLineWidth(strokeWidth * (0.45 * pathData.force[i] + 0.75))
                    }else{
                        context.setLineWidth(strokeWidth)
                    }
                    context.setStrokeColor(strokeColor.cgColor)
                    context.setLineJoin(.bevel)
                    context.setLineCap(.round)
                    context.strokePath()
                }
                context.move(to: path)
            }
            context.closePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // initial dataset
        pathData.append(PathData(path: [CGPoint](), force: [CGFloat](), type: touches.first!.type))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, var lastSet = pathData.popLast() else {
            return
        }
        
        lastSet.path.append(touch.location(in: self))
        lastSet.force.append(touch.type == .pencil ? touch.force : strokeWidth)
        pathData.append(lastSet)
        setNeedsDisplay()
    }
    
    func revertLast(){
        if !pathData.isEmpty{
            pathData.removeLast()
            setNeedsDisplay()
        }
    }
    
    func clearCanvas(){
        pathData.removeAll()
        setNeedsDisplay()
    }
    
    func exportPathData() -> [PathData]{
        return pathData
    }
    
    func setSnapShot(_ data: [PathData]){
        pathData = data
        setNeedsDisplay()
    }
    
    func export() -> UIImage? {
        if pathData.isEmpty{
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        draw(frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func refresh(){
        self.setNeedsDisplay()
    }
    
}

struct PathData{
    var path: [CGPoint]
    var force: [CGFloat]
    var type: UITouch.TouchType
}

extension UIImage {
    func toPNG() -> UIImage? {
        guard let imageData = self.pngData() else {return nil}
        guard let imagePng = UIImage(data: imageData) else {return nil}
        return imagePng
    }
}
