import Foundation
import UIKit
import HaishinKit

final class StaticImageWidget: VisualEffect {
    let filter: CIFilter? = CIFilter(name: "CISourceOverCompositing")
    var image: UIImage?
    var targetPoint: CGPoint?

    var extent: CGRect = CGRect.zero {
        didSet {
            if extent == oldValue {
                return
            }
            UIGraphicsBeginImageContext(extent.size)
            image?.draw(at: targetPoint!)
            pronama = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)
            UIGraphicsEndImageContext()
        }
    }

    var pronama: CIImage?

    override init() {
        super.init()
    }

    override func execute(_ image: CIImage) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        extent = image.extent
        filter.setValue(pronama!, forKey: "inputImage")
        filter.setValue(image, forKey: "inputBackgroundImage")
        return filter.outputImage!
    }
}
