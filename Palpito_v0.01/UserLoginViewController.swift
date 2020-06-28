//
//  UserLoginViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 17/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserLoginViewController: UIViewController {

    @IBOutlet weak var emailAddText: UITextField!
    @IBOutlet weak var passwordAddText: UITextField!
    @IBOutlet weak var userLoginView: UIView!
    
    var autoLoginCheck = false
    var uid = ""
    var pwd = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scale = view.bounds.width / userLoginView.bounds.width
                
        userLoginView.transform = CGAffineTransform(scaleX: scale, y: scale)
         
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func autoLoginCheckAction(_ sender: UIButton) {
        //print(" isSelected check.. : \(sender.isSelected) ")
        if sender.isSelected == true {
            self.autoLoginCheck = true
//            sender.isSelected = false
        } else {
            self.autoLoginCheck = false
//            sender.isSelected = true
        }
        
    }
    
    @IBAction func userLoginAction(_ sender: Any) {
        //print("userLogin check..")
        guard  let email = emailAddText.text, let password = passwordAddText.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
            } else {
                // 세션 유지 로그 아웃
                //print("로그인 체크!")
                //print(user as Any)
                guard let user = user?.user else { return }
                //print(user.uid)
                UserDefaults.standard.set(user.uid, forKey: "UserKey") // UserKey Save
                
                // 여기서 다음 화면으로 넘어아기
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "UITabBarVC") as! MainTabBarViewController
                storyboard.modalPresentationStyle = .fullScreen
                //self.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
            }
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
