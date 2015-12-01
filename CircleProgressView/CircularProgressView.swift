//
//  CircularProgressView.swift
//  CircularProgressView
//
//  Created by Rondinelli Morais on 30/11/15.
//  Copyright © 2015 Rondinelli Morais. All rights reserved.
//

import UIKit

enum TextStyle {
    case Number
    case Text
}

class ProgressLabel : UILabel {
    
    var style:TextStyle = TextStyle.Text
    
    var value:AnyObject? {
        didSet {
            if style == TextStyle.Number {
                animationLabelBaseValue( CGFloat((value as! NSNumber).floatValue) ) { (value) -> Void in
                    self.text = self.bytesText(value as NSNumber)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = bounds.size.width/2
    }
    
    private func bytesText(number:NSNumber) -> String? {
        
        let formatter = NSNumberFormatter()
        
        if number.floatValue > 1000 {
            let bytes = (number.floatValue / 1024.0)
            formatter.positiveFormat = "0.#GB"
            formatter.decimalSeparator = "."
            return formatter.stringFromNumber(NSNumber(float: bytes))
        } else if number.floatValue == 0 {
            return NSString(format: "%.0f", number.floatValue) as String
        }
        return NSString(format: "%.0fMB", number.floatValue) as String
    }
    
    private func animationLabelBaseValue(baseValue:CGFloat, executeBlock:((value:CGFloat) -> Void)?) {
        
        var value:CGFloat = 0.0
        var timerUpdateLabel:CADisplayLink? = nil
        
        let animaLabel = NSBlockOperation { () -> Void in
            
            value += ( baseValue / 100.0 );
            if value >= baseValue {
                value = baseValue
                timerUpdateLabel!.invalidate()
                timerUpdateLabel = nil
            }
            
            if executeBlock != nil {
                executeBlock!(value: value)
            }
        }
        
        timerUpdateLabel = CADisplayLink(target: animaLabel, selector: "main")
        timerUpdateLabel!.frameInterval = 1
        timerUpdateLabel!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
}

class CircularProgressView: UIView {
    
    var padding:CGFloat = 20.0
    
    var animate:Bool = false
    
    var progress: CGFloat {
        get {
            return mainArcLayer.strokeEnd
        }
        set {
            
            if (newValue > 1) {
                mainArcLayer.strokeEnd = 1
            } else if (newValue < 0) {
                mainArcLayer.strokeEnd = 0
            } else {
                mainArcLayer.strokeEnd = newValue
            }
            
            if animate {
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = newValue
                animation.duration = 0.5
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.removedOnCompletion = true
                
                mainArcLayer.removeAnimationForKey(animation.keyPath!)
                mainArcLayer.addAnimation(animation, forKey: animation.keyPath!)
            }
        }
    }
    
    var textLabel:ProgressLabel? = nil

    // --------------------------------------------------------
    // MARK: Main Layer
    // --------------------------------------------------------
    
    private var placeholderArcLayer = CAShapeLayer()
    
    var placeholderProgress: CGFloat = 1.0
    
    var placeholderLineWidth:CGFloat = 2.0 {
        didSet {
            placeholderArcLayer.lineWidth = placeholderLineWidth
        }
    }
    var placeholderStrokeColor:UIColor = UIColor.lightGrayColor() {
        didSet {
            placeholderArcLayer.strokeColor = placeholderStrokeColor.CGColor
        }
    }
    
    
    
    // --------------------------------------------------------
    // MARK: Main Layer
    // --------------------------------------------------------
    
    private var mainArcLayer = CAShapeLayer()
    
    private var fillArcLayer = CAShapeLayer()
    
    var lineWidth:CGFloat = 5.0 {
        didSet {
            mainArcLayer.lineWidth = lineWidth
        }
    }
    
    var lineCapStyle:String = kCALineCapRound {
        didSet {
            mainArcLayer.lineCap = lineCapStyle
        }
    }
    
    var strokeColor:UIColor = UIColor.redColor() {
        didSet {
            mainArcLayer.strokeColor = strokeColor.CGColor
        }
    }
    
    var fillColor:UIColor? = nil {
        didSet {
            if fillColor != nil {
                fillArcLayer.fillColor = fillColor!.CGColor
            }
        }
    }
    
    // --------------------------------------------------------
    // MARK: Methods
    // --------------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainArcLayer.frame = bounds
        mainArcLayer.path = circlePath().CGPath

        placeholderArcLayer.frame = bounds
        placeholderArcLayer.path = circlePath().CGPath
        
        fillArcLayer.frame = bounds
        fillArcLayer.path = circlePath().CGPath
    }
    
    func configure() {
        
        progress = 0.0
        fillColor = self.backgroundColor
        
        fillArcLayer.frame = bounds
        fillArcLayer.fillColor = self.backgroundColor!.CGColor
        fillArcLayer.strokeEnd = 1
        layer.addSublayer(fillArcLayer)

        placeholderArcLayer.frame = bounds
        placeholderArcLayer.lineWidth = placeholderLineWidth
        placeholderArcLayer.fillColor = UIColor.clearColor().CGColor
        placeholderArcLayer.strokeColor = placeholderStrokeColor.CGColor
        placeholderArcLayer.strokeEnd = 1
        layer.addSublayer(placeholderArcLayer)
        
        mainArcLayer.frame = bounds
        mainArcLayer.lineWidth = lineWidth
        mainArcLayer.fillColor = UIColor.clearColor().CGColor
        mainArcLayer.strokeColor = strokeColor.CGColor
        mainArcLayer.lineCap = lineCapStyle
        layer.addSublayer(mainArcLayer)
        
        // label
        self.textLabel = ProgressLabel(frame: CGRect(x: 0, y: 0, width: (bounds.size.width - padding), height: (bounds.size.height - padding)))
        self.textLabel!.center = CGPoint(x:CGRectGetMidX(bounds), y:CGRectGetMidY(bounds))
        self.textLabel!.backgroundColor = UIColor.clearColor()
        self.textLabel!.textAlignment = NSTextAlignment.Center
        self.textLabel!.font = UIFont(name: "Arial-BoldMT", size: 40.0)
        self.textLabel!.textColor = UIColor.whiteColor()
        self.textLabel!.adjustsFontSizeToFitWidth = true
        self.textLabel!.minimumScaleFactor = 0.1
        self.textLabel!.numberOfLines = 2
        self.textLabel!.style = TextStyle.Text
        addSubview(self.textLabel!)
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: (bounds.size.width - padding), height: (bounds.size.height - padding))
        circleFrame.origin.x = CGRectGetMidX(mainArcLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(mainArcLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(roundedRect: circleFrame(), cornerRadius: bounds.size.width/2)
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.locations = [0.2,0.5,1.0]
        
        let red: AnyObject = UIColor.redColor().CGColor
        let yellow: AnyObject = UIColor.yellowColor().CGColor
        let green: AnyObject = UIColor.greenColor().CGColor
        let arrayOfColors: [AnyObject] = [green, yellow, red]
        gradientLayer.colors = arrayOfColors
        
        return gradientLayer
    }
}
