import Foundation
import UIKit

fileprivate enum DisplayData {
    static let navigationItemTitle = "Settings"
}

public class SettingsViewController: UITableViewController {
    @IBOutlet weak var fpsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var videoBitrateValueSlider: UISlider!
    @IBOutlet weak var audioBitrateValueSlider: UISlider!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!


    override public func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = DisplayData.navigationItemTitle
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }

    @IBAction func fpsValueChanged(_ sender: UISegmentedControl) {
        let fpsValue: CGFloat = sender.selectedSegmentIndex == 0 ? 15.0
            : sender.selectedSegmentIndex == 1 ? 30.0
            : 60.0

        Constants.instance.fps = fpsValue
    }

    @IBAction func videoBitrateValueChanged(_ sender: UISlider) {
        let videoBitrateValue = sender.value
        Constants.instance.videoBitrate = videoBitrateValue
    }

    @IBAction func audioBitrateValueChanged(_ sender: UISlider) {
        let audioBitrateValue = sender.value
        Constants.instance.audioBitrate = audioBitrateValue
    }

    @IBAction func saveAccountData(_ sender: UIButton) {
        Constants.instance.uri = urlTextField.text ?? "UNDEFINED"
        Constants.instance.secret = secretTextField.text ?? "UNDEFINED"

        view.endEditing(true)
    }
}

private extension SettingsViewController {
    func configureView() {
        let fpsValue = Constants.instance.fps ?? 0
        let videoBitrateValue = Constants.instance.videoBitrate ?? 0
        let audioBitrateValue = Constants.instance.audioBitrate ?? 0

        let uri = Constants.instance.uri ?? "UNDEFINED"
        let secret = Constants.instance.secret ?? "UNDEFINED"

        fpsSegmentedControl.selectedSegmentIndex = fpsValue == 15.0 ? 0
            : fpsValue == 30.0 ? 1
            : 2

        videoBitrateValueSlider.value = videoBitrateValue
        audioBitrateValueSlider.value = audioBitrateValue

        urlTextField.text = uri
        secretTextField.text = secret

    }
}
