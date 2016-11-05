//
//  AlertViewController.swift
//  AlertView
//
//  Created by zwb on 2016/11/4.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit

// Animation Styles
public enum LPAnimationStyle {
    case NoAnimation, TopToBottom, BottomToTop, LeftToRight, RightToLeft
}

// Action Types
public enum LPActionType {
    case None, Selector, Closure
}

public class LPButton: UIButton {
    var actionType = LPActionType.None
    var target: AnyObject!
    var selector: Selector!
    var action: (()->Void)!
    var customBackgroundColor: UIColor?
    var customTextColor: UIColor?
    var initialTitle: String!
    var showDurationStatus: Bool=false
    
    public init() {
        super.init(frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame:CGRect) {
        super.init(frame:frame)
    }
}

public class LPAlertView: UIViewController {
    
    public struct LPAppearance {

        let kDefaultShadowOpacity: CGFloat
        let kTitleTop:CGFloat
        let kTitleHeight:CGFloat
        let kWindowWidth: CGFloat
        var kWindowHeight: CGFloat
        let kTextFieldHeight: CGFloat
        let kTextViewdHeight: CGFloat
        let kLabelWidth: CGFloat
        let kHorizontalSpacing: CGFloat
        let kVerticalSpacing: CGFloat
        let kTextAlignment: NSTextAlignment
        let kButtonHeight: CGFloat
        let contentViewColor: UIColor
        let contentViewBorderColor: UIColor
        let titleColor: UIColor
        let labelColor: UIColor
        
        // Fonts
        let kTitleFont: UIFont
        let kTextFont: UIFont
        let kLalelFont: UIFont
        let kButtonFont: UIFont
        
        // UI Options
        var showCloseButton: Bool
        var showCircularIcon: Bool
        var shouldAutoDismiss: Bool // Set this false to 'Disable' Auto hideView when SCLButton is tapped
        var contentViewCornerRadius : CGFloat
        var fieldCornerRadius : CGFloat
        var buttonCornerRadius : CGFloat
        
        // Actions
        var hideWhenBackgroundViewIsTapped: Bool
        
        init(kDefaultShadowOpacity: CGFloat = 0.7,
             kTitleTop: CGFloat = 10.0,
             kTitleHeight:CGFloat = 25.0,
             kWindowWidth: CGFloat = UIScreen.mainScreen().bounds.width - 24,
             kWindowHeight: CGFloat = 178.0,
             kTextFieldHeight: CGFloat = 45.0,
             kTextViewdHeight: CGFloat = 80.0,
             kLabelWidth: CGFloat = 70.0,
             kHorizontalSpacing: CGFloat = 80.0,
             kVerticalSpacing: CGFloat = 14.0,
             kButtonHeight: CGFloat = 45.0,
             kTitleFont: UIFont = UIFont.systemFontOfSize(20),
             kTextFont: UIFont = UIFont.systemFontOfSize(14),
             kLalelFont: UIFont = UIFont.systemFontOfSize(15),
             kButtonFont: UIFont = UIFont.boldSystemFontOfSize(14),
             showCloseButton: Bool = true,
             showCircularIcon: Bool = true,
             shouldAutoDismiss: Bool = true,
             contentViewCornerRadius: CGFloat = 10.0,
             fieldCornerRadius: CGFloat = 3.0,
             buttonCornerRadius: CGFloat = 3.0,
             hideWhenBackgroundViewIsTapped: Bool = false,
             contentViewColor: UIColor = UIColorFromRGB(0xFFFFFF),
             contentViewBorderColor: UIColor = UIColorFromRGB(0xCCCCCC),
             titleColor: UIColor = UIColorFromRGB(0x3b9fc6),
             labelColor: UIColor = UIColorFromRGB(0x4D4D4D),
             kTextAlignment:NSTextAlignment = .Center) {
        
            self.kDefaultShadowOpacity = kDefaultShadowOpacity
            self.kTitleTop = kTitleTop
            self.kTitleHeight = kTitleHeight
            self.kWindowWidth = kWindowWidth
            self.kWindowHeight = kWindowHeight
            self.kLabelWidth = kLabelWidth
            self.kTextFieldHeight = kTextFieldHeight
            self.kTextViewdHeight = kTextViewdHeight
            self.kTextAlignment = kTextAlignment
            self.kHorizontalSpacing = kHorizontalSpacing
            self.kVerticalSpacing = kVerticalSpacing
            self.kButtonHeight = kButtonHeight
            
            self.contentViewColor = contentViewColor
            self.contentViewBorderColor = contentViewBorderColor
            self.titleColor = titleColor
            self.labelColor = labelColor
            
            self.kTitleFont = kTitleFont
            self.kTextFont = kTextFont
            self.kLalelFont = kLalelFont
            self.kButtonFont = kButtonFont
        
            self.showCloseButton = showCloseButton
            self.showCircularIcon = showCircularIcon
            self.shouldAutoDismiss = shouldAutoDismiss
            self.contentViewCornerRadius = contentViewCornerRadius
            self.fieldCornerRadius = fieldCornerRadius
            self.buttonCornerRadius = buttonCornerRadius
            
            self.hideWhenBackgroundViewIsTapped = hideWhenBackgroundViewIsTapped
        }
    
        mutating func setkWindowHeight(kWindowHeight: CGFloat) {
            self.kWindowHeight = kWindowHeight
        }
    }
    
    var appearance: LPAppearance!
    
    // Members declaration
    var baseView = UIView()
    var contentView = UIView()
    var labelTitle = UILabel()
    
    private var inputs = [UITextField]()
    private var inputWithLabels = [UIView]()
    private var input = [UITextView]()
    private var buttons = [LPButton]()
    private var selfReference: LPAlertView?

    public var customSubview: UIView?
    
    public init(appearance: LPAppearance) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required public init() {
        appearance = LPAppearance()
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        appearance = LPAppearance()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // set up main view
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: appearance.kDefaultShadowOpacity)
        view.addSubview(baseView)
        
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .Center
        labelTitle.font = appearance.kTitleFont
        labelTitle.frame = CGRect(x: 12, y: appearance.kTitleTop, width: appearance.kWindowWidth - 24, height: appearance.kTitleHeight)
        
        let dividingLine = UIView()
        var dividingLineY = appearance.kTitleTop + appearance.kTitleHeight
        dividingLineY += 4
        dividingLine.backgroundColor = UIColorFromRGB(0x3b9fc6)
        dividingLine.frame = CGRect(x: 12, y: dividingLineY, width: appearance.kWindowWidth - 24, height: 1)
        contentView.addSubview(dividingLine)
        
        let cancelButton = UIButton()
        cancelButton.setImage(imageOfCross, forState: .Normal)
        cancelButton.addTarget(self, action: #selector(hideView), forControlEvents: .TouchUpInside)
        cancelButton.frame = CGRect(x: appearance.kWindowWidth - 20 - 12, y: appearance.kTitleTop, width: 20, height: 20)
        contentView.addSubview(cancelButton)
        
        contentView.backgroundColor = appearance.contentViewColor
        labelTitle.textColor = appearance.titleColor
        contentView.layer.borderColor = appearance.contentViewBorderColor.CGColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LPAlertView.tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        let sz = rv.frame.size
        
        view.frame.size = sz

        var consumedHeight: CGFloat = 0
        consumedHeight += appearance.kTitleTop + appearance.kTitleHeight
        consumedHeight += appearance.kVerticalSpacing
        consumedHeight += appearance.kTextFieldHeight * CGFloat(inputs.count)
        consumedHeight += appearance.kTextFieldHeight * CGFloat(inputWithLabels.count)
        consumedHeight += appearance.kButtonHeight * CGFloat(buttons.count)
        
        let windowHeight = consumedHeight
        
        let x = (sz.width - appearance.kWindowWidth) / 2
        var y = (sz.height - windowHeight) / 2
        
        contentView.frame = CGRect(x: x, y: y, width: appearance.kWindowWidth, height: windowHeight)
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        
        // Subtitle
        y = appearance.kTitleTop + appearance.kTitleHeight
        y += appearance.kVerticalSpacing
    
        // Text fields
        for txt in inputs {
            txt.frame = CGRect(x: appearance.kHorizontalSpacing, y: y, width: appearance.kWindowWidth - appearance.kHorizontalSpacing * 2, height: 30)
            txt.layer.cornerRadius = appearance.fieldCornerRadius
            y += appearance.kTextFieldHeight
        }
        
        // Label And Text fields
        for txt in inputWithLabels {
            txt.frame = CGRect(x: appearance.kHorizontalSpacing, y: y, width: appearance.kWindowWidth - appearance.kHorizontalSpacing * 2, height: 30)
            y += appearance.kTextFieldHeight
        }
        
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x: 12, y: y, width: appearance.kWindowWidth - 24, height: 35)
            btn.layer.cornerRadius = appearance.buttonCornerRadius
            y += appearance.kButtonHeight
        }
    }
    
    public func addPicker(title: String? = nil, singleConditionSelection data: [String], withLabel labelText: String, action: (String -> Void)?) -> LPTextField {
      
        let textfield = addTextField(title, withLabel: labelText)
        textfield.showSingleColPicker("", data: data, defaultSelectedIndex: 0, autoSetSelectedText: true) { (textField, selectedIndex, selectedValue) in
            textField.text = selectedValue
            if let action = action {
                action(selectedValue)
            }
        }
        
        return textfield
    }
    
    public func addDatePicker(title: String? = nil, withLabel labelText: String, action: (String -> Void)?) -> LPTextField {
        
        let textfield = addTextField(title, withLabel: labelText)
        textfield.text = dateforString(NSDate())
        textfield.showDatePicker("选择时间", autoSetSelectedText: true) { (textField, selectedDate) in
            let date = dateforString(selectedDate)
            textField.text = date
            if let action = action {
                action(date)
            }
        }
        
        return textfield
    }

    public func addTextField(title: String? = nil, withLabel labelText: String) -> LPTextField {

        let view = UIView()
        let textfield = addTextField(title, whetherToAdd: false)
       
        let label = UILabel()
        label.text = labelText + ":"
        label.textColor = appearance.labelColor
        label.font = appearance.kLalelFont
        label.frame = CGRect(x: 0, y: 0, width: appearance.kLabelWidth, height: 30)
        
        view.addSubview(textfield)
        view.addSubview(label)
        
        contentView.addSubview(view)
        inputWithLabels.append(view)
        return textfield
    }
    
    public func addTextField(title: String? = nil) -> UITextField {
        return addTextField(title, whetherToAdd: true)
    }

    private func addTextField(title: String? = nil, whetherToAdd: Bool) -> LPTextField {
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kTextFieldHeight)
        
        let txt = LPTextField()
        txt.borderStyle = UITextBorderStyle.RoundedRect
        txt.font = appearance.kTextFont
        txt.autocapitalizationType = .Words
        txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        
        if let placeholder = title {
            txt.placeholder = placeholder
        }
        
        if whetherToAdd {
            contentView.addSubview(txt)
            inputs.append(txt)
        } else {
            txt.frame = CGRect(x: appearance.kLabelWidth, y: 0, width: appearance.kWindowWidth - appearance.kHorizontalSpacing * 2 - appearance.kLabelWidth, height: 30)
        }
        
        return txt
    }
    
    public func addButton(title: String, backgroundColor: UIColor? = nil, textColor: UIColor? = nil, action: () -> Void) -> LPButton {
        let btn = addButton(title, backgroundColor: backgroundColor, textColor: textColor)
        btn.actionType = LPActionType.Closure
        btn.action = action
        btn.addTarget(self, action: #selector(LPAlertView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        return btn
    }
    
    public func addButton(title: String, backgroundColor: UIColor? = nil, textColor: UIColor? = nil, showDurationStatus: Bool = false, target: AnyObject, selector: Selector) -> LPButton {
        let btn = addButton(title, backgroundColor: backgroundColor, textColor: textColor)
        btn.actionType = LPActionType.Closure
        btn.target = target
        btn.selector = selector
        btn.addTarget(self, action: #selector(LPAlertView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        return btn
    }
    
    public func addButton(title: String, backgroundColor: UIColor? = nil, textColor: UIColor? = nil) -> LPButton {
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kButtonHeight)
        
        let btn = LPButton()
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColorFromRGB(0x99ca3b)
        btn.setTitle(title, forState: .Normal)
        btn.titleLabel?.font = appearance.kButtonFont
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    func buttonTapped(btn: LPButton) {

        if btn.actionType == LPActionType.Closure {
            btn.action()
        } else if btn.actionType == LPActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to: btn.target, forEvent: nil)
        } else {
            print("Unknow action type for button")
        }
        
        if view.alpha != 0.0 && appearance.shouldAutoDismiss { hideView() }
    }
    
    //Dismiss keyboard when tapped outside textfield & close AlertView when hideWhenBackgroundViewIsTapped
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        if let tappedView = gestureRecognizer.view where tappedView.hitTest(gestureRecognizer.locationInView(tappedView), withEvent: nil) == baseView
            && appearance.hideWhenBackgroundViewIsTapped {
            
            hideView()
        }
    }
    
    public func show(title: String, duration: NSTimeInterval?, completeText: String?, colorStyle: UInt? = 0x000000, colorTextButton: UInt? = 0xFFFFFF, animationStyle: LPAnimationStyle = .TopToBottom) {
        selfReference = self
        view.alpha = 0
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds
        
        if !title.isEmpty {
            self.labelTitle.text = title
        }
        
        showAnimation(animationStyle)
    }
    
    // Show animation in the alert view
    private func showAnimation(animationStyle: LPAnimationStyle = .TopToBottom, animationStartOffset: CGFloat = -400.0, boundingAnimationOffset: CGFloat = 15.0, animationDuration: NSTimeInterval = 0.2) {
        
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        var animationStartOrigin = baseView.frame.origin
        var animationCenter = rv.center
        
        switch animationStyle {
        case .NoAnimation:
            view.alpha = 1.0
            return
        
        case .TopToBottom:
            animationStartOrigin = CGPoint(x: animationStartOrigin.x, y: baseView.frame.origin.y + animationStartOffset)
            animationCenter = CGPoint(x: animationCenter.x, y: animationCenter.y + boundingAnimationOffset)
        
        case .BottomToTop:
            animationStartOrigin = CGPoint(x: animationStartOrigin.x, y: baseView.frame.origin.y - animationStartOffset)
            animationCenter = CGPoint(x: animationCenter.x, y: animationCenter.y - boundingAnimationOffset)
            
        case .LeftToRight:
            animationStartOrigin = CGPoint(x: baseView.frame.origin.x + animationStartOffset, y: animationStartOrigin.y)
            animationCenter = CGPoint(x: animationCenter.x + boundingAnimationOffset, y: animationCenter.y)
            
        case .RightToLeft:
            animationStartOrigin = CGPoint(x: baseView.frame.origin.x - animationStartOffset, y: animationStartOrigin.y)
            animationCenter = CGPoint(x: animationCenter.x - boundingAnimationOffset, y: animationCenter.y)
        }
        
        baseView.frame.origin = animationStartOrigin
        UIView.animateWithDuration(animationDuration, animations: { 
            self.view.alpha = 1.0
            self.baseView.center = animationCenter
            }) { finished in
                UIView.animateWithDuration(animationDuration, animations: { 
                    self.view.alpha = 1.0
                    self.baseView.center = rv.center
                })
        }
    }
    
    public func hideView() {
        UIView.animateWithDuration(0.2, animations: { 
            self.view.alpha = 0
            }) { finished in
                
                for button in self.buttons {
                    button.action = nil
                    button.target = nil
                    button.selector = nil
                }
                
                self.view.removeFromSuperview()
                self.selfReference = nil
        }
    }
    
    // × 图
    var imageOfCross: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 20), false, 0)
        drawCross()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 画 ×
    func drawCross() {
        // Cross Shape Drawing
        let crossShapePath = UIBezierPath()
        crossShapePath.moveToPoint(CGPoint(x: 0, y: 20))
        crossShapePath.addLineToPoint(CGPoint(x: 20, y: 0))
        crossShapePath.moveToPoint(CGPoint(x: 0, y: 0))
        crossShapePath.addLineToPoint(CGPoint(x: 20, y: 20))
        crossShapePath.lineCapStyle = CGLineCap.Square
        crossShapePath.lineJoinStyle = CGLineJoin.Round
        UIColorFromRGB(0x4D4D4D).setStroke()
        crossShapePath.lineWidth = 1
        crossShapePath.stroke()
    }
}

// 日期转化成字符串
func dateforString(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.stringFromDate(date)
}

// Helper function to convert from RGB to UIColor
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue:  CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}