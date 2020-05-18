//
//  YBButton.swift
//  
//
//  Created by Bulimac, Vlad-Claudiu on 18/05/2020.
//

import UIKit

public class YBButton : UIButton {
    
    override public var highlighted : Bool {
        didSet {
            alpha = highlighted ? 0.3 : 1.0
        }
    }
    var buttonColor:UIColor? {
        didSet {
            if let buttonColor = buttonColor {
                iconImageView.image = icon?.imageWithRenderingMode(.AlwaysTemplate)
                iconImageView.tintColor = buttonColor
                dotView.dotColor = buttonColor
            } else {
                iconImageView.image = icon
            }
        }
    }
    
    var icon:UIImage?
    var iconImageView = UIImageView()
    var textLabel = UILabel()
    var dotView = DotView()
    var buttonFont:UIFont? {
        didSet {
            textLabel.font = buttonFont
        }
    }
    var actionType:YBButtonActionType!
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    
    init(frame:CGRect,icon:UIImage?, text:String) {
        super.init(frame:frame)
        
        self.icon = icon
        let iconHeight:CGFloat = frame.height * 0.45
        iconImageView.frame = CGRect(x: 9, y: frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight)
        iconImageView.image = icon
        addSubview(iconImageView)
        
        dotView.frame = iconImageView.frame
        dotView.backgroundColor = UIColor.clearColor()
        dotView.hidden = true
        addSubview(dotView)
        
        let labelHeight = frame.height * 0.8
        textLabel.frame = CGRect(x: iconImageView.frame.maxX + 11, y: frame.midY - labelHeight/2, width: frame.width - iconImageView.frame.maxX, height: labelHeight)
        textLabel.text = text
        textLabel.textColor = UIColor.blackColor()
        textLabel.font = buttonFont
        addSubview(textLabel)
    }
    
    func appear() {
        iconImageView.transform = CGAffineTransformMakeScale(0, 0)
        textLabel.transform = CGAffineTransformMakeScale(0, 0)
        dotView.transform = CGAffineTransformMakeScale(0, 0)
        dotView.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.textLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
        })
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            
            if self.iconImageView.image == nil {
                self.dotView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            } else {
                self.iconImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }, completion: nil)
    }
    
    required public init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        UIColor(white: 0.85, alpha: 1.0).setStroke()
        let line = UIBezierPath()
        line.lineWidth = 1
        line.moveToPoint(CGPoint(x: iconImageView.frame.maxX + 5, y: frame.height))
        line.addLineToPoint(CGPoint(x: frame.width , y: frame.height))
        line.stroke()
    }
}
