//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import BitizenConnectSwift
import SafariServices
import SnapKit

class MainViewController: UIViewController {
    var actionsController: ActionsViewController!
    var api:BitizenConnectApi!
    

    @objc func connect() {
        api.connect(dappName: "ExampleDapp", dappDescription: "BitizenConnectSwift", dappUrl: URL(string: "https://safe.gnosis.io")!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        api  =  BitizenConnectApi(delegate: self)
        
        let whiteView = UIView()
        self.view.addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.text = "Bitizen SDKs Demo"
        whiteView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let content = "Simple integration with Bitizen SDKs in less than 5 mins"
        let contentBlack = "5 mins"
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 17)
        contentLabel.text = content
        contentLabel.numberOfLines = 0
        whiteView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
        
        let button = UIButton(type: .custom)
        button .setImage(UIImage(named: "sdk_logo"), for: .normal)
        button.backgroundColor = UIColor(red: 0.004, green: 0.718, blue: 0.549, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        whiteView.addSubview(button)
        button.addTarget(self, action: #selector(connect), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(contentLabel.snp.bottom).offset(15)
        }
        
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

    func didConnect(chainId: Int?, accounts: [String]?) {
        onMainThread { [unowned self] in
            self.actionsController = ActionsViewController.create(api: self.api)//: self.bitizenConnect)
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
