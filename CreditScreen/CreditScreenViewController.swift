//
//  CreditScreenViewController.swift
//  CreditScreen
//
//  Created by Prabhat Kasera on 12/28/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//
import UIKit


class CreditScreenViewController : UIViewController {
    @IBOutlet weak var slider: UISlider!
    var imageNameArray = ["1.jpg","2.jpg","3.jpg","4.jpg"]
    var dockImageArray : [UIView] = []
    @IBOutlet weak var frontImageView : UIImageView!
    @IBOutlet weak var backImageView : UIImageView!
    @IBOutlet weak var sliderView : UIView!
    
    var seekBarColor : UIColor  =  UIColor.white
    var seekBarHeight : CGFloat = 6.0
    var isSeekBarWithRoundCorner = true
    var shouldContinueRotating = true
    var seekView : UIView!
    var oldFIndex = -1
    var oldBIndex = -1
    var timer : Timer? = nil
    var previousValue : Float = 0.0
    var isScrollingLeftToRight = true
    var valueDivider : CGFloat = 0.0
    
    override func viewDidLoad() {
        slider.maximumValue = Float(imageNameArray.count) - 1.0
        slider.minimumValue = 0
        slider.value = 0.0
        slider.addTarget(self, action: #selector(didChangeSliderValue(slider:)), for: UIControlEvents.valueChanged)
        slider.addTarget(self, action: #selector(touchDownSlider(slider:)), for: UIControlEvents.touchDown)
        slider.addTarget(self, action: #selector(touchUpSlider(slider:)), for: UIControlEvents.touchUpInside)
        setupImages()
        tickTheTimer()
        self.navigationController?.navigationBar.isHidden = true
        slider.isHidden = true
        
    }
    override func viewDidLayoutSubviews() {
        valueDivider = self.sliderView.frame.width / CGFloat(imageNameArray.count)
        if self.seekView == nil {
            prepareSeekBar()
        }
        else {
            self.adjustSeekFrame()
        }
    }
    func setupImages() {
        self.frontImageView.image = UIImage(named:imageNameArray[0])
        self.backImageView.image = UIImage(named:imageNameArray[1])
    }
    func tickTheTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.slider.value = self.slider.value + 0.035
            //self.changeImage(value: self.slider.value)
            self.performOperationOnValue(value: self.slider.value)
            if self.slider.value >= self.slider.maximumValue {
                if self.shouldContinueRotating == true {
                    self.slider.value = 0.0
                }
                else {
                    timer.invalidate()
                }
            }
        })
    }
    @objc func didChangeSliderValue(slider : UISlider) {
        if slider.value < slider.maximumValue {
           //changeImage(value: slider.value)
            performOperationOnValue(value: slider.value)
        }
    }
    @objc func touchDownSlider(slider : UISlider) {
        if slider.value < slider.maximumValue {
             self.timer?.invalidate()
        }
    }
    @objc func touchUpSlider(slider : UISlider) {
        if slider.value < slider.maximumValue {
            tickTheTimer()
        }
    }
   
    func performOperationOnValue(value : Float) {
        //checking the sliding direction
        if previousValue < value {
            isScrollingLeftToRight = true
        }
        else {
            isScrollingLeftToRight = false
        }
        let parameters = getRequiredParameterBasedOn(lToRDirection: isScrollingLeftToRight,value: value, totalCount: imageNameArray.count)
        // will take decision on the basis of the value
        self.frontImageView?.alpha = parameters.alpha
        if oldFIndex != parameters.frontIndex {
            self.frontImageView?.image = UIImage(named: imageNameArray[parameters.frontIndex])
        }
        if oldBIndex != parameters.backIndex {
            self.backImageView?.image = UIImage(named: imageNameArray[parameters.backIndex])
        }
        oldBIndex = parameters.backIndex
        oldFIndex = parameters.frontIndex
        previousValue = value
        
        self.seekView.frame.origin.x = CGFloat(value) * self.valueDivider
        //scaleIndex(index: parameters.frontIndex, factor: parameters.alpha)
        
    }
    
    func getRequiredParameterBasedOn(lToRDirection : Bool, value : Float, totalCount : Int) -> (alpha : CGFloat, frontIndex : Int, backIndex : Int) {
        var alpha : CGFloat = 0.0
        let index = Int(value)
        var fIndex  = 0
        var bIndex  = 0
        
        if lToRDirection {
            fIndex = index
            if (index + 1) < totalCount {
                bIndex = index + 1
            }
        }
        else {
            bIndex = index
            if (index - 1) > 0 {
                fIndex = index - 1
            }
        }
        let floorValue = floor(value)
        alpha = 1.0 - CGFloat(value - floorValue)
        return (alpha : alpha, frontIndex : fIndex, backIndex : bIndex)
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if slider.value < slider.maximumValue {
                tickTheTimer()
            }
        }
        else if sender.state == .began {
            self.timer?.invalidate()
        }
        else {
            
            let point = sender.location(in: self.sliderView)
            let value  = Float (point.x / self.valueDivider)
            if value >= self.slider.minimumValue && value <= self.slider.maximumValue {
                slider.value = value
                self.performOperationOnValue(value: value)
            }
        }
    }
    func prepareDockImages() {
        var i : CGFloat = 0.0
        for _ in self.imageNameArray {
            let frame = CGRect(x: self.valueDivider * i , y: 0.0, width: self.valueDivider, height: 48.0)
            let view = UIView(frame: frame)
            view.transform = CGAffineTransform(scaleX: 0.1 , y: 0.1)
            view.backgroundColor = Int(i) % 2 == 0 ? UIColor.green : UIColor.red
            self.dockImageArray.append(view)
            i = i + 1.0
            self.sliderView.addSubview(view)
        }
    }
    func prepareSeekBar() {
        
        self.seekView = UIView(frame: CGRect(x: 0.0, y: UIScreen.main.bounds.height - seekBarHeight, width: self.valueDivider, height: seekBarHeight))
        self.seekView.backgroundColor = self.seekBarColor
        self.sliderView.addSubview(self.seekView)
        if isSeekBarWithRoundCorner {
            self.seekView.layer.cornerRadius = seekBarHeight / 2.0
        }
    }
    func adjustSeekFrame() {
        self.seekView.frame.origin.x = CGFloat(self.slider.value) * self.valueDivider
        self.seekView.frame.size.width = self.valueDivider
    }
    func scaleIndex(index : Int, factor : CGFloat) {
        let view = self.dockImageArray[index]
        view.transform = CGAffineTransform(scaleX: 1.0 -  factor, y: 1.0 -  factor)
    }
}
