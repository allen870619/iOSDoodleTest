//
//  Canvas.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/2/7.
//
import UIKit

class CanvasView: UIView{
    // draw style
    var strokeWidth: CGFloat = 4
    var strokeColor: UIColor = .black
    
    // data
    private var paintData = PaintData()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // draw path context
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // stroke setup
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineJoin(.bevel)
        context.setLineCap(.round)
        
        // add points
        paintData.strokeList.forEach { (pathData) in
            // after, smooth but little bit slower(using three points)
            if pathData.path.count >= 3{
                var last1: CGPoint!
                var last2: CGPoint!
                
                for (i, path) in (pathData.path.enumerated()){
                    if i > 0 && i % 2 == 0{
                        context.move(to: last1)
                        let x =  (2 * last2.x)  - ((last1.x + path.x) / 2)
                        let y =  (2 * last2.y)  - ((last1.y + path.y) / 2)
                        context.addQuadCurve(to: path, control: CGPoint(x: x, y: y))
                        
                        // line style
                        if pathData.type == .pencil{
                            context.setLineWidth(strokeWidth * (0.45 * pathData.force[i] + 0.75))
                        }else{
                            context.setLineWidth(strokeWidth)
                        }
                        
                        // draw
                        context.strokePath()
                    }
                    // shift point
                    last1 = last2
                    last2 = path
                }
            }
            
            // before, not smooth but faster
            //            for (i, path) in (pathData.path.enumerated()){
            //                if i > 0{
            //                    context.addLine(to: path)
            //
            //                    // line style
            //                    if pathData.type == .pencil{
            //                        context.setLineWidth(strokeWidth * (0.45 * pathData.force[i] + 0.75))
            //                    }else{
            //                        context.setLineWidth(strokeWidth)
            //                    }
            //
            //                    // draw
            //                    context.strokePath()
            //                }
            //
            //                // shift point
            //                context.move(to: path)
            //            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // initial dataset
        paintData.strokeList.append(StrokePath(path: [CGPoint](), force: [CGFloat](), type: touches.first!.type))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, var lastSet = paintData.strokeList.popLast() else {
            return
        }
        
        lastSet.path.append(touch.location(in: self))
        lastSet.force.append(touch.type == .pencil ? touch.force : strokeWidth)
        paintData.strokeList.append(lastSet)
        setNeedsDisplay()
    }
    
    func revertLast(){
        if !paintData.strokeList.isEmpty{
            paintData.strokeList.removeLast()
            setNeedsDisplay()
        }
    }
    
    func clearCanvas(){
        paintData.strokeList.removeAll()
        setNeedsDisplay()
    }
    
    func getPaintData() -> PaintData{
        return paintData
    }
    
    func loadSnapShot(_ data: PaintData){
        paintData = data
        setNeedsDisplay()
    }
    
    func export() -> UIImage? {
        if paintData.strokeList.isEmpty{
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


struct PaintData{ // whole doodle
    var strokeList: [StrokePath] = []
}

struct StrokePath{ // each single stroke
    var path: [CGPoint]
    var force: [CGFloat]
    var type: UITouch.TouchType
}
