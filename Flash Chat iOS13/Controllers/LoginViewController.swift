//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e.localizedDescription)
                    
                    let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default)
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true)
                }else{
                    //navigate to chatview controller as user created successfully
                    self.performSegue(withIdentifier: Constants.Segues.loginToChat, sender: self)
                }
            }
        }else{
            print("invalid input for email and password")
        }
    }
    
}
