//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import BitizenConnectSwift

class ApiCell : UITableViewCell {
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 12
        self.contentView.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.font = UIFont.systemFont(ofSize: 17)
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/// For testing we recommend to use Rainbow Wallet
/// MetaMask does not support `eth_gasPrice` and `eth_getTransactionCount` at the moment of testing 01.09.2021
class ActionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var api:BitizenConnectApi!
    var chainId: Int!
    var accounts: [String]!
    var selectIndex: Int = 0
    var accountLabel = UILabel()

    static func create(api: BitizenConnectApi, accounts: [String], chainId: Int) -> ActionsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller =  storyboard.instantiateViewController(withIdentifier: "ActionsViewController") as! ActionsViewController
        controller.api = api
        controller.accounts = accounts
        controller.chainId = chainId
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.965, alpha: 1)
        
        let bigTitle = UILabel()
        bigTitle.text = "Wallet"
        bigTitle.font = UIFont.boldSystemFont(ofSize: 34)
        bigTitle.textColor = UIColor.black
        self.view.addSubview(bigTitle)
        bigTitle.sizeToFit()
        bigTitle.frame = CGRect(x: 15, y: 15, width: bigTitle.frame.size.width, height: bigTitle.frame.size.height)
        
        let chainLabel = UILabel()
        chainLabel.text = "chainId:\(String(chainId))"
        chainLabel.font = UIFont.systemFont(ofSize: 13)
        chainLabel.textColor =  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        chainLabel.sizeToFit()
        self.view.addSubview(chainLabel)
        chainLabel.frame = CGRect(x: bigTitle.frame.origin.x, y: bigTitle.frame.maxY + 10, width: chainLabel.frame.size.width, height: chainLabel.frame.size.height)
        
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor.white
        button.frame = CGRectMake(bigTitle.frame.origin.x, chainLabel.frame.maxY + 10, self.view.frame.size.width - 2 * bigTitle.frame.origin.x, 60)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        self.view.addSubview(button)
        
        let leftLabel = UILabel()
        leftLabel.text = "Connected"
        leftLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        leftLabel.font = UIFont.systemFont(ofSize: 17)
        button.addSubview(leftLabel)
        leftLabel.sizeToFit()
        leftLabel.frame = CGRect(x: 20, y: 0, width: leftLabel.frame.size.width, height: button.frame.height)
        
        accountLabel.textColor = UIColor.black
        accountLabel.font = UIFont.systemFont(ofSize: 17)
        button.addSubview(accountLabel)

        if (accounts.count > 1) {
            let imageView = UIImageView(image: UIImage(named: "Vector"))
            button.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(7)
                make.height.equalTo(12)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalToSuperview()
            }
            
            accountLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.right.equalTo(imageView.snp.left).offset(-5)
            }
        } else {
            accountLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.right.equalToSuperview().offset(-20)
            }
        }
        
        changeAccount()
        
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 0.5)
        self.view.addSubview(line)
        line.frame = CGRect(x: bigTitle.frame.origin.x, y: button.frame.maxY + 10 , width: self.view.frame.width - bigTitle.frame.origin.x, height: 1)
        
        let apiLabel = UILabel()
        self.view.addSubview(apiLabel)
        apiLabel.font = UIFont.boldSystemFont(ofSize: 17)
        apiLabel.textColor = UIColor.black
        apiLabel.text = "API"
        apiLabel.sizeToFit()
        apiLabel.frame = CGRect(x: bigTitle.frame.origin.x, y: line.frame.maxY + 10, width: apiLabel.frame.width, height: apiLabel.frame.height)
        
        let table = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(table)
        table.register(ApiCell.self, forCellReuseIdentifier: NSStringFromClass(ApiCell.self))
        table.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(apiLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell: ApiCell  = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ApiCell.self)) as! ApiCell
            switch (indexPath.section) {
            case 0:
                cell.label.text = "Personal Sign"
            case 1:
                cell.label.text = "Sign typed date"
            case 2:
                cell.label.text = "ETH send transaction"
            case 3:
                cell.label.text = "Disconnect"
            default: break
            }
            return cell
        }
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))!
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func changeAccount() {
        let str: String = accounts[self.selectIndex]
        let range = NSRange(location: 6, length: str.lengthOfBytes(using: String.Encoding.utf8) - 6 - 4)
        accountLabel.text =  (str as NSString).replacingCharacters(in: range, with: "...")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            api.personalSign(message: "Hi there!", account: walletAccount) {  [weak self] response in
                self?.handleReponse(response, expecting: "Signature")
            }
        case 1:
            api.ethSignTypedData(message: Stub.typedData, account: walletAccount) {  [weak self] response in
                self?.handleReponse(response, expecting: "Signature")
            }
        case 2:
            let transaction = Stub.transaction(from: self.walletAccount, nonce: "0")
            api.ethSendTransaction(transaction: transaction) {  [weak self] response in
                self?.handleReponse(response, expecting: "Hash")
            }
        case 3:
            api.disconnect()
            dismiss(animated: true)
        default:break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 60
        }
        return 10
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        api.disconnect()
    }
    
    @objc func buttonPressed() {
        if (accounts.count > 1) {
            let alert = UIAlertController(title: "Select your address", message: nil, preferredStyle: .actionSheet)
            for index in 0..<accounts.count  {
                alert.addAction(UIAlertAction(title: accounts[index], style: .default,handler: { [weak self]  _ in
                    self?.selectIndex = index
                    self?.changeAccount()
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }

    var walletAccount: String {
        return accounts[self.selectIndex]
    }


    private func handleReponse(_ response: Response, expecting: String) {
        DispatchQueue.main.async {
            if let error = response.error {
                self.show(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert))
                return
            }
            do {
                let result = try response.result(as: String.self)
                self.show(UIAlertController(title: expecting, message: result, preferredStyle: .alert))
            } catch {
                self.show(UIAlertController(title: "Error",
                                       message: "Unexpected response type error: \(error)",
                                       preferredStyle: .alert))
            }
        }
    }

    private func show(_ alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.present(alert, animated: true)
    }
}

fileprivate enum Stub {
    /// https://docs.walletconnect.org/json-rpc-api-methods/ethereum#example-parameters
    static let typedData = """
{
    "types": {
        "EIP712Domain": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "version",
                "type": "string"
            },
            {
                "name": "chainId",
                "type": "uint256"
            },
            {
                "name": "verifyingContract",
                "type": "address"
            }
        ],
        "Person": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "wallet",
                "type": "address"
            }
        ],
        "Mail": [
            {
                "name": "from",
                "type": "Person"
            },
            {
                "name": "to",
                "type": "Person"
            },
            {
                "name": "contents",
                "type": "string"
            }
        ]
    },
    "primaryType": "Mail",
    "domain": {
        "name": "Ether Mail",
        "version": "1",
        "chainId": 1,
        "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
    },
    "message": {
        "from": {
            "name": "Cow",
            "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
        },
        "to": {
            "name": "Bob",
            "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
        },
        "contents": "Hello, Bob!"
    }
}
"""

    /// https://docs.walletconnect.org/json-rpc-api-methods/ethereum#example-parameters-1
    static func transaction(from address: String, nonce: String) -> Client.Transaction {
        return Client.Transaction(from: address,
                                  to: "0xd46e8dd67c5d32be8058bb8eb970870f07244567",
                                  data: "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675",
                                  gas: "0x76c0", // 30400
                                  gasPrice: "0x9184e72a000", // 10000000000000
                                  value: "0x9184e72a", // 2441406250
                                  nonce: nonce,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }

    /// https://docs.walletconnect.org/json-rpc-api-methods/ethereum#example-5
    static let data = "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f07244567"

}
