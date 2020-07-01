//
//  ViewController.swift
//  SecNinjazKeyboard
//
//  Created by Aminjoni Abdullozoda on 4/25/19.
//  Copyright © 2019 Aminjoni Abdullozoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var doneTF: UITextField!
    @IBOutlet weak var nextTF: UITextField!
    @IBOutlet weak var defTF: UITextField!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTF.delegate = self
        doneTF.delegate = self
        nextTF.delegate = self
        defTF.delegate = self
        searchTF.enablesReturnKeyAutomatically = true
        
        let tap  = UITapGestureRecognizer(target: self, action: #selector(endEditin))
        self.view.addGestureRecognizer(tap)

    }

    @objc func endEditin() {
        self.view.endEditing(true)
    }
   
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == searchTF {

            if (textField.text?.count)! >= 3 {
                textField.enablesReturnKeyAutomatically = false
            }
            
        }
        
        switch textField {
        case searchTF:
            textField.backgroundColor = .cyan
        case doneTF:
            returnAction()
        case nextTF:
            textField.backgroundColor = .green
        default:
            textField.backgroundColor = .magenta
        }
        
        
        
        return true
    }
    
    
    
    
    func returnAction() {
        
        print("Configure The Return Action Here...")
        resignFirstResponder()
        self.view.backgroundColor = .blue
        self.view.endEditing(true)
        
    }


}

