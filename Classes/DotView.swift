//
//  DotView.swift
//  
//
//  Created by Bulimac, Vlad-Claudiu on 18/05/2020.
//

import UIKit

class DotView:UIView {
    var dotColor = UIColor.blackColor()
    
    override func drawRect(rect: CGRect) {
        dotColor.setFill()
        let circle = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: 3, startAngle: 0, endAngle: 360, clockwise: true)
        circle.fill()
    }
}

