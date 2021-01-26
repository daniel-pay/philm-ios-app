//
//  UIView+Extension.swift
//  TestProject
//
//  Created by developer on 6/20/20.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit


extension UIView {
    
    func round(corners: UIRectCorner, cornerRadius: Double) {
        
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}
