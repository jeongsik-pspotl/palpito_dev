//
//  AgeAddViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 28/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit

class AgeAddViewController: UIViewController, UITextFieldDelegate {
    
    var mUserCreate = UserCreate()
    var beforeCreateUserData = UserInfo()
    
    @IBOutlet weak var ageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("UserInfo data call check .... :  \(beforeCreateUserData)")
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        beforeCreateUserData.age = mUserCreate.ageAdd(age: Int(ageTextField.text!)!)!
        //print(" check data :  \(beforeCreateUserData)")
        if segue.identifier == "nextUserGender" {
            (segue.destination as! GenderViewController).beforeCreateUserData = beforeCreateUserData
        }
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
