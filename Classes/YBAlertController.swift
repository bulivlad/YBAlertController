//
//  YBAlertController.swift
//  YBAlertController
//
//  Created by Yuta on 2016/01/12.
//  Copyright © 2016年 Yabuzaki Yuta. All rights reserved.
//

import UIKit

public class YBAlertController: UIViewController, UIGestureRecognizerDelegate {
    
    let ybTag = 2345
    
    // background
    public var overlayColor = UIColor(white: 0, alpha: 0.2)
    
    // titleLabel
    public var titleFont = UIFont(name: "Questrial", size: 15)
    public var titleTextColor = UIColor.black
    
    // message
    public var message:String?
    public var messageLabel = UILabel()
    public var messageFont = UIFont(name: "Questrial", size: 13)
    public var messageTextColor = UIColor.lightGray
    
    // button
    public var buttonHeight:CGFloat = 50
    public var buttonTextColor = UIColor.black
    public var buttonIconColor:UIColor?
    public var buttons: [YBButton] = []
    public var buttonFont = UIFont(name: "Questrial", size: 15)
    
    // cancelButton
    public var cancelButtonTitle:String?
    public var cancelButtonFont = UIFont(name: "Questrial", size: 14)
    public var cancelButtonTextColor = UIColor.darkGray
    
    public var animated = true
    public var containerView = UIView()
    public var style = YBAlertControllerStyle.ActionSheet
    public var touchingOutsideDismiss:Bool? //
    
    private var instance:YBAlertController!
    private var currentStatusBarStyle:UIStatusBarStyle?
    private var showing = false
    private var currentOrientation:UIDeviceOrientation?
    private var cancelButton = UIButton()
    
    var cardId: String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        view.frame = UIScreen.main.bounds
        
        containerView.backgroundColor = UIColor.white
        containerView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(YBAlertController.dismissLocal))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(YBAlertController.changedOrientation(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public convenience init(style: YBAlertControllerStyle) {
        self.init()
        self.style = style
    }
    
    public convenience init(title:String?, message:String?, style: YBAlertControllerStyle) {
        self.init()
        self.style = style
        self.title = title
        self.message = message
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func changedOrientation(notification: NSNotification) {
        if showing && style == YBAlertControllerStyle.ActionSheet {
            let value = currentOrientation?.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            return
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touchingOutsideDismiss == false { return false }
        if touch.view != gestureRecognizer.view { return false }
        return true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show() {
        view.backgroundColor = overlayColor
        if touchingOutsideDismiss == nil {
            touchingOutsideDismiss = style == .ActionSheet ? true : false
        }
        
        initContainerView()
        
        if style == YBAlertControllerStyle.ActionSheet {
            UIView.animate(withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: .curveEaseIn,
                animations: {
                    self.containerView.frame.origin.y = self.view.frame.height - self.containerView.frame.height
                    self.getTopViewController()?.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                },
                completion: { (finished) in
                    if self.animated {
                        self.startButtonAppearAnimation()
                        if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                            self.startCancelButtonAppearAnimation()
                        }
                        
                    }
                }
            )
        } else {
            self.containerView.frame.origin.y = self.view.frame.height/2 - self.containerView.frame.height/2
            containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            containerView.alpha = 0.0
            UIView.animate(withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: .curveEaseIn,
                animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                },
                completion: { (finished) in
                    if self.animated {
                        self.startButtonAppearAnimation()
                        if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                            self.startCancelButtonAppearAnimation()
                        }
                        
                    }
                }
            )
        }
    }
    
    @objc public func dismissLocal() {
        showing = false
        if let statusBarStyle = currentStatusBarStyle {
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
        
        if style == .ActionSheet {
            UIView.animate(withDuration: 0.2,
                animations: {
                    self.containerView.frame.origin.y = self.view.frame.height
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                    self.getTopViewController()?.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                },
                completion:  { (finished) in
                    self.view.removeFromSuperview()
            })
        } else {
            UIView.animate(withDuration: 0.2,
                animations: {
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                    self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self.containerView.alpha = 0
                },
                completion:  { (finished) in
                    self.view.removeFromSuperview()
            })
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        return topVC
    }
    
    private func initContainerView() {
        
        for subView in containerView.subviews {
            subView.removeFromSuperview()
        }
        for subView in self.view.subviews {
            subView.removeFromSuperview()
        }
        
        showing = true
        instance = self
        let viewWidth = (style == .ActionSheet) ? view.frame.width : view.frame.width * 0.9
        
        currentOrientation = UIDevice.current.orientation
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == UIInterfaceOrientation.portrait {
            currentOrientation = UIDeviceOrientation.portrait
        }
        
        var posY:CGFloat = 0
        if let title = title, title != ""  {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: buttonHeight*0.92))
            titleLabel.text = title
            titleLabel.font = titleFont
            titleLabel.textAlignment = .center
            titleLabel.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            titleLabel.textColor = titleTextColor
            containerView.addSubview(titleLabel)
            
            let line = UIView(frame: CGRect(x: 0, y: titleLabel.frame.height, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            containerView.addSubview(line)
            posY = titleLabel.frame.height + line.frame.height
        } else {
            posY = 0
        }
        
        if let message = message, message != "" {
            let paddingY:CGFloat = 8
            let paddingX:CGFloat = 10
            messageLabel.font = messageFont
            messageLabel.textColor = UIColor.gray
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textColor = messageTextColor
            let f = CGSize(width: viewWidth - paddingX*2, height: CGFloat.greatestFiniteMagnitude)
            let rect = messageLabel.sizeThatFits(f)
            messageLabel.frame = CGRect(x: paddingX, y: posY + paddingY, width: rect.width, height: rect.height)
            containerView.addSubview(messageLabel)
            containerView.addConstraints([
                NSLayoutConstraint(item: messageLabel, attribute: .rightMargin, relatedBy: .equal, toItem: containerView, attribute: .rightMargin, multiplier: 1, constant: -paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .leftMargin, relatedBy: .equal, toItem: containerView, attribute: .leftMargin, multiplier: 1.0, constant: paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: posY + paddingY),
                NSLayoutConstraint(item: messageLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: rect.height)
            ])
            
            posY = messageLabel.frame.maxY + paddingY
            
            let line = UIView(frame: CGRect(x: 0, y: posY, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            containerView.addSubview(line)
            
            posY += line.frame.height
        }
        
        for i in 0..<buttons.count {
            buttons[i].frame.origin.y = posY
            buttons[i].backgroundColor = UIColor.white
            buttons[i].buttonColor = buttonIconColor
            buttons[i].frame = CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight)
            buttons[i].textLabel.textColor = buttonTextColor
            buttons[i].buttonFont = buttonFont
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(buttons[i])
            
            containerView.addConstraints([
                NSLayoutConstraint(item: buttons[i], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: buttonHeight),
                NSLayoutConstraint(item: buttons[i], attribute: .rightMargin, relatedBy: .equal, toItem: containerView, attribute: .rightMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: .leftMargin, relatedBy: .equal, toItem: containerView, attribute: .leftMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: posY)
            ])
            posY += buttons[i].frame.height
        }
        
        if let cancelTitle = cancelButtonTitle, cancelTitle != "" {
            cancelButton = UIButton(frame: CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight * 0.9))
            cancelButton.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            cancelButton.titleLabel?.font = cancelButtonFont
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
            cancelButton.setTitleColor(cancelButtonTextColor, for: .normal)
            cancelButton.addTarget(self, action: #selector(YBAlertController.dismissLocal), for: .touchUpInside)
            containerView.addSubview(cancelButton)
            posY += cancelButton.frame.height
        }
        
        let safeAreaBottomInset = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: (view.frame.width - viewWidth) / 2, y:view.frame.height , width: viewWidth, height: posY + safeAreaBottomInset)
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)
        
        if style == YBAlertControllerStyle.ActionSheet {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY + safeAreaBottomInset)
            ])
        } else {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.9, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY)
            ])
        }
        
        if let window = UIApplication.shared.keyWindow {
            if window.viewWithTag(ybTag) == nil {
                view.tag = ybTag
                window.addSubview(view)
            }
        }
        
        currentStatusBarStyle = UIApplication.shared.statusBarStyle
        if style == .ActionSheet { UIApplication.shared.statusBarStyle = .lightContent }
        
        if animated {
            cancelButton.isHidden = true
            buttons.forEach {
                $0.iconImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
                $0.textLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                $0.dotView.isHidden = true
            }
        } else {
            buttons.forEach {
                if $0.iconImageView.image == nil {
                    $0.dotView.isHidden = false
                }
            }
        }
    }
    
    private func startButtonAppearAnimation() {
        for i in 0..<buttons.count {
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time = DispatchQueue.SchedulerTimeType.init(DispatchTime.init(uptimeNanoseconds: UInt64(delay * Double(i))))
            DispatchQueue.main.schedule(after: time) {
                self.buttons[i].appear()
            }
        }
    }
    
    private func startCancelButtonAppearAnimation() {
        cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 0, y: 0)
        cancelButton.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.2 * Double(buttons.count + 1) - 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
    }
    
    public func addButton(icon:UIImage?, title:String, noIconStyle: NoIconViewStyle?, action:@escaping (YBButton?)->Void) {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, noIconStyle: noIconStyle, text: title)
        button.actionType = YBButtonActionType.Closure
        button.action = action
        button.buttonColor = buttonIconColor
        button.buttonFont = buttonFont
        button.addTarget(self, action: #selector(YBAlertController.buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(icon:UIImage?, imageHeight: CGFloat, imageWidth: CGFloat, title:String, noIconStyle: NoIconViewStyle?, action:@escaping (YBButton?)->Void) -> YBButton {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, noIconStyle: noIconStyle, imageHeight: imageHeight, imageWidth: imageWidth, text: title)
        button.actionType = YBButtonActionType.Closure
        button.action = action
        button.buttonColor = buttonIconColor
        button.buttonFont = buttonFont
        button.addTarget(self, action: #selector(YBAlertController.buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
        
        return button
    }
    
    public func addButton(icon:UIImage?, title:String, target:AnyObject, selector:Selector, noIconStyle: NoIconViewStyle?) {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, noIconStyle: noIconStyle, text: title)
        button.actionType = YBButtonActionType.Selector
        button.actionType = YBButtonActionType.Closure
        button.buttonColor = buttonIconColor
        button.target = target
        button.selector = selector
        button.buttonFont = buttonFont
        button.addTarget(self, action: #selector(YBAlertController.buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(icon:UIImage?, imageHeight: CGFloat, imageWidth: CGFloat, title:String, target:AnyObject, selector:Selector, noIconStyle: NoIconViewStyle?) {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, noIconStyle: noIconStyle, imageHeight: imageHeight, imageWidth: imageWidth, text: title)
        button.actionType = YBButtonActionType.Selector
        button.buttonColor = buttonIconColor
        button.target = target
        button.selector = selector
        button.buttonFont = buttonFont
        button.addTarget(self, action: #selector(YBAlertController.buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(title:String, noIconStyle: NoIconViewStyle?, action:@escaping (YBButton?)->Void) {
        addButton(icon: nil, title: title, noIconStyle: noIconStyle, action: action)
    }
    
    public func addButton(title:String, noIconStyle: NoIconViewStyle?, target:AnyObject, selector:Selector) {
        addButton(icon: nil, title: title, target: target, selector: selector, noIconStyle: noIconStyle)
    }
    
    @objc func buttonTapped(button: YBButton) {
        if button.actionType == YBButtonActionType.Closure {
            button.action(button)
        } else if button.actionType == YBButtonActionType.Selector {
            let control = UIControl()
            control.sendAction(button.selector, to: button.target, for: nil)
        }
        dismissLocal()
    }
}
