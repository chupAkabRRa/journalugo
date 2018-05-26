//
//  RunningTextLine.swift
//  journalugo
//
//  Created by Dima Kostenich on 5/26/18.
//  Copyright © 2018 Hyped Inc. All rights reserved.
//

import UIKit
import HaishinKit

private class RunningTextLine: UIView {
    private var textArray = [String]()
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
        
        self.backgroundColor = UIColor.yellow
        leadingBuffer = CGFloat(frame.size.width) - 1.0
        super.clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLabel(text: String) {
        layer.removeAllAnimations()
        textArray.append(text)
        setup()
    }
    
    func getImage() -> CIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let result: CIImage = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)!
        //return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        return result
    }
    
    func reinitLabels() {
        var textToDisplay: String = "***    "
        for text in textArray {
            textToDisplay += text + "    ***    ";
        }
        
        let labelAtIndex0 = labelArray[0]
        labelAtIndex0.text = textToDisplay
        let labelAtIndex1 = labelArray[1]
        
        let sizeOfText = labelAtIndex0.sizeThatFits(CGSize.zero)
        timeInterval = TimeInterval(textToDisplay.count / 5)
        
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
    
    func setup() {
        if (textArray.count > 0) {
            if (labelArray.count == 0) {
                let label = UILabel()
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
    }
    
    func animateLabelText() {
        let labelAtIndex0 = labelArray[0]
        let labelAtIndex1 = labelArray[1]
        
        UIView.animate(withDuration: timeInterval, delay: loopStartDelay, options: [.curveLinear, .repeat], animations: {
            labelAtIndex0.frame = CGRect(x: -self.rect0.size.width,y: 0, width: self.rect0.size.width,height: self.rect0.size.height)
            labelAtIndex1.frame = CGRect(x: labelAtIndex0.frame.origin.x + labelAtIndex0.frame.size.width,y: 0,width: labelAtIndex1.frame.size.width,height: labelAtIndex1.frame.size.height)
        }, completion: nil)
    }
}

class RunningTextLineWidget: VisualEffect {
    private var internalLabel: RunningTextLine!
    let filter: CIFilter? = CIFilter(name: "CISourceOverCompositing")
    
    public init(frame: CGRect) {
        internalLabel = RunningTextLine(frame: frame);
    }
    
    func addLabel(text: String) {
        internalLabel.addLabel(text: text)
    }
    
    override func execute(_ image: CIImage) -> CIImage {
        let result: CIImage = internalLabel.getImage()
        filter!.setValue(result, forKey: "inputImage")
        filter!.setValue(image, forKey: "inputBackgroundImage")
        
        return filter!.outputImage!
    }
}
