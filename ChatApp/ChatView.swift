//
//  ChatView.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/02.
//

import Foundation
import UIKit

class ChatView: UIViewController,UITableViewDelegate,UITableViewDataSource, InputViewDelegate {
    
    
    var roomData:ChatRoom!
    var chatData:[ChatText] = []
    var database = DatabaseHelper()

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var bottomInputView: InputView = {
        let view = InputView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        return bottomInputView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.getUserName(userID: roomData.userID, result: {
            name in
            self.navigationItem.title = name
        })
        database.chatDataListener(roomID: roomData.roomID, result: {
            result in
                self.chatData = result
                self.messageUpdated()
        })
        
        tableView.keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60.0, right: 0)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollToBottom()
        }
    }

    @objc func keyboardWillHide(){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func sendTapped(text: String) {
        database.sendChatMessage(roomID: roomData.roomID, text: text)
    }
    
    func scrollToBottom(){
        let rowNum = tableView.numberOfRows(inSection: 0)
        if rowNum != 0 {
            tableView.scrollToRow(at: IndexPath(row: rowNum-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func messageUpdated(){
        tableView.reloadData()
        scrollToBottom()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = chatData[indexPath.row]
        let cell:UITableViewCell
        if data.userID == AuthHelper().uid() {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2")!
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")!
        }
        let imageView = cell.viewWithTag(2) as! UIImageView
        imageView.layer.cornerRadius = imageView.frame.height * 0.5
        imageView.clipsToBounds = true
        database.getImage(userID: data.userID, imageView: imageView)
        let label = cell.viewWithTag(1) as! UILabel
        label.text = data.text
        label.numberOfLines = 0
        label.sizeToFit()
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = chatData[indexPath.row]
        let cell:UITableViewCell
        if data.userID == AuthHelper().uid() {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2")!
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")!
        }
        let label = cell.viewWithTag(1) as! UILabel
        label.text = data.text
        label.numberOfLines = 0
        label.sizeToFit()
        return max(label.frame.size.height - 20, 60);
    }

}
