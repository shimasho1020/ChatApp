//
//  DatabaseHelper.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/01.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
//import FirebaseStorageUI
import SDWebImage

class DatabaseHelper {
    
    let uid = AuthHelper().uid()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    func getMyRoomList(result:@escaping([ChatRoom]) -> Void){
        db.collection("room").whereField("user", arrayContains: uid).addSnapshotListener({
            (querySnapshot, error) in
            var roomList:[ChatRoom] = []
            if error == nil {
                for doc in querySnapshot!.documents {
                    let data = doc.data()
                    guard let users = data["user"] as? [String] else { return }
                    if users.count != 2 { return }
                    var user = ""
                    if users[0] == self.uid {
                        user = users[1]
                    } else {
                        user = users[0]
                    }
                    roomList.append(ChatRoom(roomID:doc.documentID, userID: user))
                }
                result(roomList)
            }
        })
    }
    
    func getUserInfo(userID:String,result:@escaping(String) -> Void){
        db.collection("user").document(userID).getDocument(completion: {
            (querySnapshot, error) in
            if error == nil {
                let data = querySnapshot?.data()
                guard let name = data?["name"] as! String? else {
                    result("")
                    return
                }
                result(name)
            } else {
                result("")
            }
        })
    }
    
    func getUserName(userID:String,result:@escaping(String) -> Void) {
        db.collection("user").document(userID).getDocument(completion: {
            (doc, error) in
            if error == nil {
                let data = doc?.data()
                guard let name = data?["name"] as! String? else { return }
                result(name)
            }
        })
    }

    func resisterUserInfo(name:String,image:UIImage){
        db.collection("user").document(uid).setData(["name":name])
        let resized = image.resize(toWidth: 300)
        guard let imageData = resized!.jpegData(compressionQuality:1) else { return }
        storage.child("image/\(uid).jpeg").putData(imageData, metadata: nil)
    }

    func getImage(userID:String,imageView:UIImageView){
//        let reference = storage.child("image/"+userID+".jpeg") as! URL
        let imageRef = Storage.storage().reference(withPath: "image/"+userID+".jpeg")
        imageRef.downloadURL { url, error in
                if let url = url {
                    imageView.sd_setImage(with: url)
                }
            }
    }
    
    func createRoom(userID:String){
        db.collection("room").addDocument(data: ["user":[userID,uid]])
    }
    
    func sendChatMessage(roomID:String,text:String){
        db.collection("room").document(roomID).collection("chat").addDocument(data: ["userID":uid,"text":text,"time":time(nil)])
    }
    
    func chatDataListener(roomID:String,result:@escaping([ChatText]) -> Void){
        db.collection("room").document(roomID).collection("chat").order(by: "time").addSnapshotListener({
            (querySnapshot, error) in
            if error == nil{
                var chatList:[ChatText] = []
                for doc in querySnapshot!.documents{
                    let data = doc.data()
                    guard let text = data["text"] as! String? else { break }
                    guard let userID = data["userID"] as! String? else { break }
                    chatList.append(ChatText(text: text, userID: userID))
                }
                result(chatList)
            }
        })
    }

}

struct ChatRoom {
    let roomID:String
    let userID:String
}

struct ChatText {
    let text:String
    let userID:String
}
