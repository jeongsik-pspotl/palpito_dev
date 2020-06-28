//
//  PopUpViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 01/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var mUserCreate = UserCreate()
    var beforeCreateUserData = UserInfo()
    @IBOutlet weak var signUpNickName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // signUpNickName.text = beforeCreateUserData.name! + "님과 함께하게 되어"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeTap_Inside(_ sender: UIButton) {
//        dismiss(animated: true)
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
