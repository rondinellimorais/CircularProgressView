//
//  ViewController.swift
//  CircleProgressView
//
//  Created by Rondinelli Morais on 27/11/15.
//  Copyright © 2015 Rondinelli Morais. All rights reserved.
//

import UIKit

extension UIColor {

    class func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(255) + 1)
        let g = CGFloat(arc4random_uniform(255) + 1)
        let b = CGFloat(arc4random_uniform(255) + 1)
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}

class ViewController: UIViewController {

    // ---------------------------------------------------------------
    // MARK: Vars
    // ---------------------------------------------------------------
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var innerLineWidthSlider: UISlider!
    @IBOutlet weak var outLineWidthSlider: UISlider!
    
    
    // ---------------------------------------------------------------
    // MARK: Cycle
    // ---------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // ---------------------------------------------------------------
    // MARK: actions
    // ---------------------------------------------------------------
    @IBAction func lineWidthChange(slider: UISlider) {
        
        if slider == innerLineWidthSlider {
            self.circularProgressView.placeholderLineWidth = CGFloat(self.innerLineWidthSlider.value)
        }
        
        if slider == outLineWidthSlider {
            self.circularProgressView.lineWidth = CGFloat(self.outLineWidthSlider.value)
        }
    }
    
    @IBAction func changeColor(sender: AnyObject) {
        self.circularProgressView.strokeColor = UIColor.randomColor()
        self.circularProgressView.placeholderStrokeColor = UIColor.randomColor()
        self.circularProgressView.fillColor = UIColor.randomColor()
    }
    
    @IBAction func randomValue(sender: AnyObject) {
        self.circularProgressView.progress = CGFloat(arc4random_uniform(10))/10.0
        print(self.circularProgressView.progress)
    }
    
    @IBAction func changeValue(slider: UISlider) {
        self.circularProgressView.progress = CGFloat(slider.value)
        print(self.circularProgressView.progress)
    }
    
    @IBAction func changeLineCap(_switch: UISwitch) {

        if _switch.on {
            self.circularProgressView.lineCapStyle = kCALineCapRound
        } else {
            self.circularProgressView.lineCapStyle = kCALineCapButt // or kCALineCapSquare
        }
    }
    
    @IBAction func changeValueNumber(sender: AnyObject) {
        self.circularProgressView.textLabel!.style = TextStyle.Number
        
        let freeUnits = CGFloat(10240.0)
        let ratedVolume = CGFloat( arc4random_uniform(1024) * 10 )
        
        self.circularProgressView.progress = (ratedVolume / freeUnits)
        
        print(self.circularProgressView.progress)
        
        self.circularProgressView.textLabel!.value = NSNumber(float:Float(ratedVolume))
    }
}

