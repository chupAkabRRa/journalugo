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
    static let startStreamButtonTitle = "Start"
    static let stopStreamButtonTitle = "Stop"
}

public class MainViewController: UIViewController {
    @IBOutlet weak var lfView: GLLFView!

    var rtmpConnection: RTMPConnection = RTMPConnection()
    var rtmpStream: RTMPStream!
    
    // Set of different widgets for demo
    var widgetRunningText: RunningTextLineWidget!

    var currentPosition: AVCaptureDevice.Position = .back

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        setupRTMPStream()
        
        widgetRunningText = RunningTextLineWidget(frame: CGRect(x: 0, y: 0, width: lfView.frame.width - 15, height: 50))
        widgetRunningText.addLabel(text: "ZDAROVA BRO KAK DELA ZHITUHA U MENYA VSE OK SIZHU POGROMIRUY")
        self.view.insertSubview(widgetRunningText.internalLabel, belowSubview: lfView)
        _ = rtmpStream.registerEffect(video: widgetRunningText)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        configureRTMPStream()
        configureCameraView()

        print(Constants.instance)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        rtmpStream.close()
        rtmpStream.dispose()
    }

    @IBAction func swapCamera(_ sender: UIBarButtonItem) {
        let delta = 0.1

        let startTransition1 = BlurTransition(blurStrength: 6.0)
        let startTransition2 = BlurTransition(blurStrength: 6.0)
        let startTransition3 = BlurTransition(blurStrength: 6.0)
        let startTransition4 = BlurTransition(blurStrength: 6.0)

        _ = rtmpStream.registerEffect(video: startTransition1)
        DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
            _ = self.rtmpStream.registerEffect(video: startTransition2)
            DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                _ = self.rtmpStream.registerEffect(video: startTransition3)
                DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                    _ = self.rtmpStream.registerEffect(video: startTransition4)

                    let position: AVCaptureDevice.Position = self.currentPosition == .back ? .front : .back
                    self.rtmpStream.attachCamera(DeviceUtil.device(withPosition: position)) { error in
                        print("Error on swapping camera: \(error)")
                    }
                    self.currentPosition = position

                    DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                        _ = self.rtmpStream.unregisterEffect(video: startTransition4)
                        DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                            _ = self.rtmpStream.unregisterEffect(video: startTransition3)
                            DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                                _ = self.rtmpStream.unregisterEffect(video: startTransition2)
                                DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
                                    _ = self.rtmpStream.unregisterEffect(video: startTransition1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func pauseButtonClicked(_ sender: UIButton) {
        rtmpStream.togglePause()
    }

    @IBAction func startStream(_ sender: UIButton) {
        if sender.titleLabel?.text == DisplayData.startStreamButtonTitle {
            UIApplication.shared.isIdleTimerDisabled = true
            rtmpConnection.addEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusHandler), observer: self)
            rtmpConnection.connect(Constants.instance.uri!)
            sender.setTitle(DisplayData.stopStreamButtonTitle, for: .normal)
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            rtmpConnection.close()
            rtmpConnection.removeEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusHandler), observer: self)
            _ = rtmpStream.unregisterEffect(video: widgetRunningText)
            sender.setTitle(DisplayData.startStreamButtonTitle, for: .normal)
        }
    }

    @objc func rtmpStatusHandler(_ notification: Notification) {
        let e: Event = Event.from(notification)
        if let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String {
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                rtmpStream!.publish(Constants.instance.secret!)
            default:
                break
            }
        }
    }
}

private extension MainViewController {
    func configureView() {
        navigationItem.title = DisplayData.navigationItemTitle
    }

    func setupRTMPStream() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
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

    func configureRTMPStream() {
        rtmpStream.captureSettings["fps"] = Constants.instance.fps
        rtmpStream.audioSettings["bitrate"] = Constants.instance.audioBitrate! * 1024
        rtmpStream.videoSettings["bitrate"] = Constants.instance.videoBitrate! * 1024

        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            print("Error on attach audio to stream: \(error)")
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            print("Error on attach video to stream: \(error)")
        }
    }

    func configureCameraView() {
        lfView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        lfView.attachStream(rtmpStream)
    }
}
