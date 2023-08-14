//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var message : [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessage()

    }
    
    func loadMessage(){
        
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            
            self.message = []
            if let e = error{
                print("Following error occurred while loading messages: \(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for document in snapshotDocuments{
                        if let messageSender = document.data()[K.FStore.senderField] as? String,
                           let messageBody = document.data()[K.FStore.bodyField] as? String{
                            self.message.append(Message(sender: messageSender, body: messageBody))
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.message.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(
                data: [K.FStore.senderField: messageSender,
                       K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                           if let e = error{
                               print("Error occurred while tyring to save: \(e)")
                           }else{
                               print("successfully saved")
                               DispatchQueue.main.async {
                                   self.messageTextfield.text = ""
                               }
                               
                           }
                       }
        }
    }
    
    @IBAction func logOutClick(_ sender: UIBarButtonItem) {
        
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageValue = message[indexPath.row]
        
        let messageSender = messageValue.sender
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messageValue.body
        
        if messageSender == Auth.auth().currentUser?.email{
            
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            
        }else{
            
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lighBlue)
            cell.label.textColor = UIColor(named: K.BrandColors.blue)
            
        }
        
        return cell
    }
    
    
}
