//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBOutlet weak var warningDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningDisplay.text = nil
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
//            print("yolo")
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    self.warningDisplay.text = e.localizedDescription
                    print(e.localizedDescription)
                }else{
                    self.warningDisplay.text = nil
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
            
            
        }
        
        
    }
    
}
