import HaishinKit
import UIKit
import Foundation

final class BlurTransition: VisualEffect {
    let filter: CIFilter? = CIFilter(name: "CIBoxBlur")
    private var blurStrength: NSNumber?

    init(blurStrength: NSNumber) {
        self.blurStrength = blurStrength
    }

    override func execute(_ image: CIImage) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }

        filter.setValue(image, forKey: "inputImage")
        filter.setValue(blurStrength, forKey: "inputRadius")

        return filter.outputImage!
    }
}
