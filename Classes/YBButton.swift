//
//  YBButton.swift
//
//  Created by Bulimac, Vlad-Claudiu on 18/05/2020.
//  Copyright © 2020 Nexa Dev. All rights reserved.
//

import UIKit

public class YBButton : UIButton {
    
    override public var isHighlighted : Bool {
        didSet {
            alpha = isHighlighted ? 0.3 : 1.0
        }
    }
    var buttonColor:UIColor? {
        didSet {
            if let buttonColor = buttonColor {
                iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = buttonColor
                dotView = NoIconView.instance(style: .plusView)
                dotView.color = buttonColor
            } else {
                iconImageView.image = icon
            }
        }
    }
    
    var icon:UIImage?
    var iconImageView = UIImageView()
    var textLabel = UILabel()
    var dotView: AbstractNoIconView!
    var buttonFont:UIFont? {
        didSet {
            textLabel.font = buttonFont
        }
    }
    var actionType:YBButtonActionType!
    var target:AnyObject!
    var selector:Selector!
    var action:((YBButton?)->Void)!
    private var data: [String: String] = [String: String]()
    
    init(frame:CGRect, icon:UIImage?, noIconStyle: NoIconViewStyle?, text:String) {
        super.init(frame:frame)
        
        self.icon = icon
        let iconHeight:CGFloat = frame.height * 0.45
        iconImageView.frame = CGRect(x: 9, y: frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight)
        iconImageView.image = icon
        addSubview(iconImageView)
        
        dotView = NoIconView.instance(style: noIconStyle)
        dotView.frame = iconImageView.frame
        dotView.backgroundColor = UIColor.clear
        dotView.isHidden = true
        addSubview(dotView)
        
        let labelHeight = frame.height * 0.8
        textLabel.frame = CGRect(x: iconImageView.frame.maxX + 11, y: frame.midY - labelHeight/2, width: frame.width - iconImageView.frame.maxX, height: labelHeight)
        textLabel.text = text
        textLabel.textColor = UIColor.black
        textLabel.font = buttonFont
        addSubview(textLabel)
    }
    
    init(frame:CGRect, icon:UIImage?, noIconStyle: NoIconViewStyle?, imageHeight: CGFloat, imageWidth: CGFloat, text:String) {
        super.init(frame:frame)
        
        self.icon = icon
        iconImageView.frame = CGRect(x: 9, y: frame.height/2 - imageHeight/2, width: imageWidth, height: imageHeight)
        iconImageView.image = icon
        addSubview(iconImageView)
        
        dotView = NoIconView.instance(style: noIconStyle)
        dotView.frame = iconImageView.frame
        dotView.backgroundColor = UIColor.clear
        dotView.isHidden = true
        addSubview(dotView)
        
        let labelHeight = frame.height * 0.8
        textLabel.frame = CGRect(x: iconImageView.frame.maxX + 11, y: frame.midY - labelHeight/2, width: frame.width - iconImageView.frame.maxX, height: labelHeight)
        textLabel.text = text
        textLabel.textColor = UIColor.black
        textLabel.font = buttonFont
        addSubview(textLabel)
    }
    
    func appear() {
        iconImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        textLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
        dotView.transform = CGAffineTransform(scaleX: 0, y: 0)
        dotView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.textLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            if self.iconImageView.image == nil {
                self.dotView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.iconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }, completion: nil)
    }
    
    required public init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        UIColor(white: 0.85, alpha: 1.0).setStroke()
        let line = UIBezierPath()
        line.lineWidth = 1
        line.move(to: CGPoint(x: iconImageView.frame.maxX + 5, y: frame.height))
        line.addLine(to: CGPoint(x: frame.width , y: frame.height))
        line.stroke()
    }
    
    func getData(forKey key: String) -> String? {
        return data[key]
    }
    
    func putData(value: String, forKey key: String) {
        data[key] = value
    }
}
