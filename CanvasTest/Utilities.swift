//
//  Utilities.swift
//  CanvasTest
//
//  Created by Lee Yen Lin on 2022/3/5.
//

import UIKit

extension UIImage {
    func toPNG() -> UIImage? {
        guard let imageData = self.pngData() else {return nil}
        guard let imagePng = UIImage(data: imageData) else {return nil}
        return imagePng
    }
}
