//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    //reference to our firestore database
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //hidding navigation back button
        navigationItem.hidesBackButton = true
        
        title = Constants.appName
        
        //no need for the delegate (can be use if table has selectable cells)
        //tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            
            db.collection(Constants.FStore.collectionName).addDocument(data: [Constants.FStore.senderField: messageSender, Constants.FStore.bodyField: messageBody, Constants.FStore.dateField: Date().timeIntervalSince1970], completion: { (error) in
                if let e = error{
                    print("There was an issue saving data to firestore, \(e)")
                }else{
                    self.messageTextfield.text = ""
                    print("Data saved successfully.")
                }})
            
        }
    }
    
    @IBAction func btnLogoutTouchUp(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            //go back to main page by using our navigation controller
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    
    func loadMessages(){
        
        //ordering the collection
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener {(querySnapshot, error) in
            if let e = error{
                print("There was an issue retrieving data from firestore. \(e.localizedDescription)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    //empty previous msg before adding new/old once
                    self.messages = []
                    
                    for document in snapshotDocuments {
                        let data = document.data()
                        if let sender = data[Constants.FStore.senderField] as? String,
                            let message = data[Constants.FStore.bodyField] as? String{
                            
                            let newMessage = Message(sender: sender, body: message)
                            self.messages.append(newMessage)
                        }
                    }
                    //working with UI in a clouser
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        //scroll down to bottom (latest messages)
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
    
}

extension ChatViewController: UITableViewDataSource{
    
    //number of rows in our table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // need to return the cell that should display in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        //identifier is same as the name we have for our reusable cell on storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell  //forcing the class must be the custom one we created
        
        cell.lblMessage.text = message.body
        
        //message from current user
        if message.sender == Auth.auth().currentUser?.email{
            cell.imgLeft.isHidden = true
            cell.imgRight.isHidden = false
            cell.viewSpacing.isHidden = false
            cell.viewMessageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.lblMessage.textColor = UIColor(named: Constants.BrandColors.purple)

        }else{
            //msg from another user
            cell.imgLeft.isHidden = false
            cell.imgRight.isHidden = true
            cell.viewMessageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.lblMessage.textColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.putRightSpacing()
        }
        
        return cell
    }
}
