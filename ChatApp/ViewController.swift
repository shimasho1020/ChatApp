//
//  ViewController.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2022/12/31.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    var dataHelper:DatabaseHelper!
    var roomList:[ChatRoom] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = AuthHelper().uid()
        print("USER_ID: "+uid)
        if uid == "" {
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            dataHelper = DatabaseHelper()
            dataHelper.getMyRoomList(result: {
                result in
                self.roomList = result
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        AuthHelper().signout()
        viewDidLoad()
//        performSegue(withIdentifier: "login", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return roomList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = roomList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let imageView = cell?.viewWithTag(1) as! UIImageView
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        dataHelper.getImage(userID: cellData.userID, imageView: imageView)
        let nameLabel = cell?.viewWithTag(2) as! UILabel
        dataHelper.getUserName(userID: cellData.userID, result: {
            name in
            nameLabel.text = name
        })
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "chat", sender: roomList[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            let VC = segue.destination as! ChatView
            let data = sender as! ChatRoom
            VC.roomData = data
        }
        if segue.identifier == "login" {
            // 遷移先のViewControllerを取得
            let VC = segue.destination as! LoginView
            // 遷移先のプロパティに処理ごと渡す
            VC.resultHandler = { text in
                // 引数を使ってoutputLabelの値を更新する処理
                self.viewDidLoad()
            }
        }
    }
    
}

