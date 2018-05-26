//
//  BadgeWidget.swift
//  journalugo
//
//  Created by Dima Kostenich on 5/26/18.
//  Copyright © 2018 Hyped Inc. All rights reserved.
//

import UIKit
import HaishinKit

class BadgeTextLine: UIView {
    public var image: CIImage?

    private var labelText : String?
    // rect for text info
    private var rect0: CGRect!
    // rect for spaces (so, text info can be removed)
    private var rect1: CGRect!
    private var labelArray = [UILabel]()
    private var timeInterval: TimeInterval!
    // offset from left edge of outer frame
    private var leadingBuffer = CGFloat(0.0)
    private let loopStartDelay = 0.0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        super.clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var text: String? {
        didSet {
            layer.removeAllAnimations()
            labelText = text
            setup()
        }
    }
    
    var cb : (() -> ())?
    
    func getImage() {
        DispatchQueue.main.async {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.bounds.width, height: 240), false, 0)
            self.drawHierarchy(in: CGRect(x: 0, y: 0, width: self.bounds.width, height: 80), afterScreenUpdates: true)
            self.image = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)!
            UIGraphicsEndImageContext()
        }
    }
    
    func reinitLabels() {
        if let textToDisplay = labelText
        {
            let labelAtIndex0 = labelArray[0]
            labelAtIndex0.text = textToDisplay
            let labelAtIndex1 = labelArray[1]
            
            let sizeOfText = labelAtIndex0.sizeThatFits(CGSize.zero)
            timeInterval = TimeInterval(textToDisplay.count / 10)
            
            leadingBuffer = -sizeOfText.width
            rect0 = CGRect(x: leadingBuffer, y: 0, width: sizeOfText.width, height: self.bounds.size.height)
            rect1 = CGRect(x: rect0.origin.x + rect0.size.width, y: 0, width: sizeOfText.width, height: self.bounds.size.height)
            
            labelAtIndex0.frame = rect0
            
            let str: String = ""
            let strEmpty = str.padding(toLength: textToDisplay.count, withPad: " ", startingAt: 0)
            labelAtIndex1.text = strEmpty
            labelAtIndex1.frame = rect1
            
            self.labelArray[0] = labelAtIndex0
            self.labelArray[1] = labelAtIndex1
        }
    }
    
    func setup() {
        if (labelArray.count == 0) {
            let label = UILabel()
            label.backgroundColor = UIColor.red
            label.frame = CGRect.zero
            labelArray.append(label)
            self.addSubview(label)
            
            let additionalLabel = UILabel()
            labelArray.append(additionalLabel)
            self.addSubview(additionalLabel)
        }
        
        reinitLabels()
        animateLabelText()
    }
    
    func animateLabelText() {
        let labelAtIndex0 = labelArray[0]
        let labelAtIndex1 = labelArray[1]
        
        UIView.animate(withDuration: timeInterval, delay: loopStartDelay, options: [.curveLinear], animations: {
            labelAtIndex1.frame = CGRect(x: self.rect1.size.width, y: 0,width: labelAtIndex1.frame.size.width,height: labelAtIndex1.frame.size.height)
            labelAtIndex0.frame = CGRect(x: labelAtIndex1.frame.origin.x - labelAtIndex0.frame.size.width, y: 0, width: self.rect0.size.width,height: self.rect0.size.height)
        }, completion: {finished in
                self.cb?()
            }
        )
    }
}

class BadgeWidget: VisualEffect {
    public var internalLabel: BadgeTextLine!
    let filter: CIFilter? = CIFilter(name: "CISourceOverCompositing")
    
    public init(frame: CGRect) {
        internalLabel = BadgeTextLine(frame: frame);
    }
    
    func addLabel(text: String) {
        internalLabel.text = text
    }
    
    override func execute(_ image: CIImage) -> CIImage {
        internalLabel.getImage()
        guard let result = internalLabel.image else {
            return CIImage.empty()
        }
        
        filter!.setValue(result, forKey: "inputImage")
        filter!.setValue(image, forKey: "inputBackgroundImage")
        
        return filter!.outputImage!
    }
}
