//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var actionsController: ActionsViewController!
    var walletConnect: WalletConnect!

    @IBAction func connect(_ sender: Any) {
        let connectionUrl = walletConnect.connect()
        
        print(connectionUrl)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIApplication.shared.open(URL(string: connectionUrl)!, options: [:], completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        walletConnect = WalletConnect(delegate: self)
        walletConnect.reconnectIfNeeded()
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

extension MainViewController: WalletConnectDelegate {
    func failedToConnect() {
        onMainThread { [unowned self] in
            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        onMainThread { [unowned self] in
            self.actionsController = ActionsViewController.create(walletConnect: self.walletConnect)
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
