//
//  LoginView.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/01.
//

import UIKit

class LoginView: UIViewController {

    @IBOutlet weak var emailFeild: UITextField!
    @IBOutlet weak var passwordFeild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AuthHelper().uid() != "" {
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        AuthHelper().login(email: emailFeild.text!, password: passwordFeild.text!, result: {
            success in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("ログイン成功")
            } else {
                self.showError()
            }
        })
    }
    
    func showError(){
        let dialog = UIAlertController(title: "エラー", message: "メールアドレス、またはパスワードが間違っています。", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(dialog, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
