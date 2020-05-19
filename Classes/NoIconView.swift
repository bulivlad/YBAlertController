//
//  NoIconView.swift
//
//  Created by Bulimac, Vlad-Claudiu on 18/05/2020.
//  Copyright © 2020 Nexa Dev. All rights reserved.
//

import UIKit

public enum NoIconViewStyle {
    case dotView
    case plusView
}

public class NoIconView {
    private let style: NoIconViewStyle!
    init(style: NoIconViewStyle) {
        self.style = style
    }
    
    static func instance(style: NoIconViewStyle?) -> AbstractNoIconView {
        switch style {
        case .dotView:
            return DotView()
        case .plusView:
            return PlusView()
        default:
            return DotView()
        }
    }
}

protocol AbstractNoIconView: UIView {
    var color: UIColor! { get set }
}

extension AbstractNoIconView {
    var color: UIColor {
        get {
            return UIColor.black
        }
        set {
        }
    }
}

class PlusView: UIView, AbstractNoIconView {
    var color: UIColor!
    
    override func draw(_ rect: CGRect) {
        color.setFill()
        let plusSize: CGFloat = 15
        let circle = UIBezierPath()
        circle.move(to: CGPoint(x: frame.width/2 - plusSize/2, y: frame.height/2))
        circle.addLine(to: CGPoint(x: frame.width/2 + plusSize/2, y: frame.height/2))
        circle.move(to: CGPoint(x: frame.width/2, y: frame.height/2 - plusSize/2))
        circle.addLine(to: CGPoint(x: frame.width/2, y: frame.height/2 + plusSize/2))
        circle.stroke()
        circle.fill()
    }
}

class DotView: UIView, AbstractNoIconView {
    var color: UIColor!
    
    override func draw(_ rect: CGRect) {
        color.setFill()
        let circle = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: 3, startAngle: 0, endAngle: 360, clockwise: true)
        circle.fill()
    }
}

