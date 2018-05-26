import Foundation
import CoreGraphics

public struct Constants {
    static var instance: Constants = Constants()

    var uri: String? = "rtmp://a.rtmp.youtube.com/live2"
    var secret: String? = "wmxa-8wmx-9up2-amjd"

    var fps: CGFloat? = 30.0
    var videoBitrate: Float? = 160.0
    var audioBitrate: Float? = 32.0
}
