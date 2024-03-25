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
    
    //to keep the txtField in the view
    var originalYPosition : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //hidding navigation back button
        navigationItem.hidesBackButton = true
        
        title = Constants.appName
        
        //no need for the delegate (can be use if table has selectable cells)
        //tableView.delegate = self
        tableView.dataSource = self
        
        //need to register the custom created cell with this table view
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.register(UINib(nibName: Constants.cellNibNameRec, bundle: nil), forCellReuseIdentifier: Constants.cellReceivedIdentifier)
        
        loadMessages()
        
        // Listen for keyboard appearances and disappearances
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //hide keyboard when we touch outside textfield
        self.hideKeyboardWhenTappedAround()
        
        //for return key
        messageTextfield.delegate = self
        
        //to move view y position on keyboard show/hide
        originalYPosition = self.view.frame.origin.y
        
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        //make the view looks in the visible position
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            //getting y position default view
            if originalYPosition <= self.view.frame.origin.y{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillDisappear(notification: NSNotification) {
        //make the view looks as default
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            //getting y position default view
            if originalYPosition != self.view.frame.origin.y{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let result = messageTextfield.text?.count{
            if result > 0{
                sendMessage()
            }
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
                        if self.messages.count > 0{
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(){
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            if !messageBody.isEmpty{
                db.collection(Constants.FStore.collectionName).addDocument(data: [Constants.FStore.senderField: messageSender, Constants.FStore.bodyField: messageBody, Constants.FStore.dateField: Date().timeIntervalSince1970], completion: { (error) in
                    if let e = error{
                        print("There was an issue saving data to firestore, \(e)")
                    }else{
                        self.messageTextfield.text = ""
                        print("Data saved successfully.")
                    }})
            }
            
        }
    }
    
}

//MARK: - TableView DataSource setup
extension ChatViewController: UITableViewDataSource{
    
    //number of rows in our table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // need to return the cell that should display in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if Auth.auth().currentUser?.email == message.sender{
            //my msg
            //identifier is same as the name we have for our reusable cell on storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell  //forcing the class must be the custom one we created
            
            cell.lblMessage.text = message.body
            
            cell.imgLeft.isHidden = true
            cell.imgRight.isHidden = false
            cell.viewSpacing.isHidden = false
            cell.viewMessageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.lblMessage.textColor = UIColor(named: Constants.BrandColors.purple)

            return cell
            
        }else{
            // msg from other users
            //identifier is same as the name we have for our reusable cell on storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReceivedIdentifier, for: indexPath) as! ReceivedMessageCell  //forcing the class must be the custom one we created
            
            cell.lblMessage.text = message.body
            let firstLetter = String(message.sender[message.sender.startIndex])
            
            cell.viewMessageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.lblMessage.textColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.imgSender.image = UIImage(systemName: firstLetter + ".circle.fill")
            
            return cell
        }
        
    }
}

//MARK: - UITextFieldDelegates
extension ChatViewController: UITextFieldDelegate{
    
    //to send message with enter/return key in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

//MARK: - Handeling keyboard hide
extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        //so that we can keep interecting with sendbutton
        tap.cancelsTouchesInView = true
        
        view.addGestureRecognizer(tap)
    }
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


