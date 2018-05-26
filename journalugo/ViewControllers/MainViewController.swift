import Foundation
import UIKit
import HaishinKit
import AVFoundation
import VideoToolbox
import Photos

let sampleRate: Double = 44_100

class ExampleRecorderDelegate: DefaultAVMixerRecorderDelegate {
    override func didFinishWriting(_ recorder: AVMixerRecorder) {
        guard let writer: AVAssetWriter = recorder.writer else { return }
        PHPhotoLibrary.shared().performChanges({() -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: writer.outputURL)
        }, completionHandler: { (_, error) -> Void in
            do {
                try FileManager.default.removeItem(at: writer.outputURL)
            } catch let error {
                print(error)
            }
        })
    }
}

fileprivate enum DisplayData {
    static let navigationItemTitle = "Stream"
}

public class MainViewController: UIViewController {
    @IBOutlet weak var lfView: LFView!

    var rtmpConnection: RTMPConnection = RTMPConnection()
    var rtmpStream: RTMPStream!

    var currentPosition: AVCaptureDevice.Position = .back

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = DisplayData.navigationItemTitle

        self.rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.syncOrientation = true
        rtmpStream.captureSettings = [
            "sessionPreset": AVCaptureSession.Preset.hd1280x720.rawValue,
            "continuousAutofocus": true,
            "continuousExposure": true
        ]
        rtmpStream.videoSettings = [
            "width": 720,
            "height": 1280
        ]
        rtmpStream.audioSettings = [
            "sampleRate": sampleRate
        ]
        rtmpStream.mixer.recorder.delegate = ExampleRecorderDelegate()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        rtmpStream.captureSettings["fps"] = Constants.instance.fps
        rtmpStream.audioSettings["bitrate"] = Constants.instance.audioBitrate! * 1024
        rtmpStream.videoSettings["bitrate"] = Constants.instance.videoBitrate! * 1024

        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            print("Error on attach audio to stream: \(error)")
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            print("Error on attach video to stream: \(error)")
        }

        lfView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        lfView.attachStream(rtmpStream)

        print(Constants.instance)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        rtmpStream.close()
        rtmpStream.dispose()
    }

    @IBAction func swapCamera(_ sender: UIBarButtonItem) {
        let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: position)) { error in
            print("Error on swapping camera: \(error)")
        }

        currentPosition = position
    }
}
