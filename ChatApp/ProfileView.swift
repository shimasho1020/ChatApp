//
//  ProfileView.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/03.
//

import UIKit

class ProfileView: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    let uid = AuthHelper().uid()
    let database = DatabaseHelper()
    var selfImageData:Data!
    var resultHandler: ((Data) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.getUserName(userID: uid, result: {
            name in
            self.nameField.text = name
        })
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImage)))
        
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        guard let data = selfImageData else{return}
        let image = UIImage(data: data)
        imageView.image = image
    }
    
    @objc func onImage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func onChange(_ sender: Any) {
        if nameField.text!.count < 3 || nameField.text!.count > 11 {
            showError(message: "名前は3字以上10字以内で設定してください。")
            return
        }
        DatabaseHelper().resisterUserInfo(name: nameField.text!, image: imageView.image!, result: {result in
            if let handler = self.resultHandler {
                handler(result)
            }
        })
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showError(message:String){
        let dialog = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(dialog, animated: true, completion: nil)
    }

}
