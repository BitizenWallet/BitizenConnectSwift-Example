//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SDWebImage
import BitizenConnectSwift
import SafariServices

class MainViewController: UIViewController {
    var actionsController: ActionsViewController!
    var bitizenConnect: BitizenConnectExample!
    @IBOutlet var connectButton: UIButton!

    @IBAction func connect(_ sender: Any) {
        let connectionUrl = bitizenConnect.connect()
        let url = URL(string: connectionUrl)!;
        print(connectionUrl)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIApplication.shared.open(url, options: [.universalLinksOnly : true]) { (success) in
                if(!success){
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true, completion: nil)
                }
                else{
                    print("working!!")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let transformer = SDImageResizingTransformer(size: CGSize(width: 40, height: 40), scaleMode: .fill)
        connectButton.sd_setImage(with: URL.init(string: BitizenConnect.LOGO_URI), for: .normal, placeholderImage: nil, context: [.imageTransformer: transformer])
        connectButton.layer.cornerRadius = 10
        connectButton.layer.borderWidth = 2
        connectButton.layer.borderColor = UIColor.link.cgColor
                
        bitizenConnect = BitizenConnectExample(delegate: self)
        bitizenConnect.reconnectIfNeeded()
    }

    func onMainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}

extension MainViewController: BitizenConnectDelegate {
    func failedToConnect() {
        onMainThread { [unowned self] in
            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        onMainThread { [unowned self] in
            self.actionsController = ActionsViewController.create(bitizenConnect: self.bitizenConnect)
            if self.presentedViewController == nil {
                self.present(self.actionsController, animated: false)
            }
        }
    }

    func didDisconnect() {
        onMainThread { [unowned self] in
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false)
            }
            UIAlertController.showDisconnected(from: self)
        }
    }
}

extension UIAlertController {
    func withCloseButton() -> UIAlertController {
        addAction(UIAlertAction(title: "Close", style: .cancel))
        return self
    }

    static func showFailedToConnect(from controller: UIViewController) {
        let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }

    static func showDisconnected(from controller: UIViewController) {
        let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }
}
