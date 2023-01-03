//
//  addFriendView.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/02.
//

import Foundation
import UIKit

class addFriendView: UIViewController {

    @IBOutlet weak var qrView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idFeild: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    let uid = AuthHelper().uid()
    let database = DatabaseHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = uid
        qrView.image = makeQRCode(text: uid)
        database.getUserName(userID: uid, result: {
            name in
            self.nameLabel.text = name
        })

    }
    
    @IBAction func onSearch(_ sender: Any) {
        conform(id: idFeild.text!)
    }
    @IBAction func onCopy(_ sender: Any) {
        UIPasteboard.general.string = uid
    }
    
    func conform(id:String){
        database.getUserInfo(userID: id, result: {
            result in
            if result == "" {
                self.showError(message: "存在しないidです。")
            } else {
                self.performSegue(withIdentifier: "conform", sender: UserData(id: id, name: result))
            }
        })
    }
    
    func showError(message:String){
        let dialog = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(dialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conform"{
            let vc = segue.destination as! ConformView
            let data = sender as! UserData
            vc.userID = data.id
            vc.name = data.name
        }
        if segue.identifier == "qr"{
            let vc = segue.destination as! QRScanner
            vc.qrScaned = {
                id in
                self.conform(id: id)
            }
        }
    }
    
    func makeQRCode(text: String) -> UIImage? {
        guard let data = text.data(using: .utf8) else { return nil }
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "H"])!
        return UIImage(ciImage: qr.outputImage!)
    }
    
}

class ConformView:UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var userID = ""
    var name = ""
    
    var database = DatabaseHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name
        database.getImage(userID: userID, imageView: imageView)
        imageView.layer.cornerRadius = imageView.frame.size.height * 0.5
        imageView.clipsToBounds = true
    }
    
    @IBAction func onAdd(_ sender: Any) {
        database.createRoom(userID: userID)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

struct UserData{
    let id:String
    let name:String
}
