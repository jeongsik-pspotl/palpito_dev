//
//  ViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 27/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: ExtensionVC {

    var uid = ""
    var pwd = ""
    var myStage = ""
    var loginCheckYn = "notSelected"
    
    var sv:UIView = UIView.init()
    
    @IBOutlet weak var emailCheck: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    @IBOutlet weak var alreadyAccount: UIButton!
    @IBOutlet weak var addAccount: UIButton!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var autoLoginCheck: UIButton!
    
    deinit {
        //print("deinit start page")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //sv = UIViewController.displaySpinner(onView: self.view)
        //sv.removeFromSuperview()
        let scale = view.bounds.width / startView.bounds.width
        
        startView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // 강도 설정
        if let myStage = UserDefaults.standard.string(forKey: "myStage"){
            self.myStage = myStage
        }else {
            UserDefaults.standard.set("SL2" , forKey: "myStage")
        }
        
        if let autoLoginCheckVal = UserDefaults.standard.string(forKey: "isAutoLoginCheck"){
            self.loginCheckYn = autoLoginCheckVal
            if self.loginCheckYn == "selected" {
                autoLoginCheck.isSelected = true
            }else if self.loginCheckYn == "notSelected" {
                autoLoginCheck.isSelected = false
            }else {
                autoLoginCheck.isSelected = false
            }
            
        }
        
        if let userId = UserDefaults.standard.string(forKey: "id"){
            self.uid = userId
        }
        
        if let userPwd = UserDefaults.standard.string(forKey: "pwd"){
            self.pwd = userPwd
            
            if autoLoginCheck.isSelected == true {
                self.sv = UIViewController.displaySpinner(onView: self.view)
                Auth.auth().signIn(withEmail: self.uid, password: self.pwd) { (user, error) in
                    
                    if error != nil {
                        // AuthErrorCode.init(rawValue: <#T##Int#>)
                        //print(error?.localizedDescription as Any)
                        //print(error.unsafelyUnwrapped)
                    } else {
                        // 세션 유지 로그 아웃
                        //print("로그인 체크!")
                        //print(user as Any)
                        guard let user = user?.user else { return }
                        //print(user.uid)
                        UserDefaults.standard.set(user.uid, forKey: "UserKey") // UserKey Save
                        
                        // 여기서 다음 화면으로 넘어아기
                        // 모달 방식 에서 네비게이션 방식으로 수정하기
                        let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "UITabBarVC") as! MainTabBarViewController
                        storyboard.modalPresentationStyle = .fullScreen
                        //self.modalPresentationStyle = .fullScreen
                        self.sv.removeFromSuperview()
                        self.present(storyboard, animated: true, completion: nil)
                    }
                }
                
            }
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sv.layoutIfNeeded()
        
        if let autoLoginCheckVal = UserDefaults.standard.string(forKey: "isAutoLoginCheck"){
            self.loginCheckYn = autoLoginCheckVal
            if self.loginCheckYn == "selected" {
                autoLoginCheck.isSelected = true
            }else if self.loginCheckYn == "notSelected" {
                autoLoginCheck.isSelected = false
            }else {
                autoLoginCheck.isSelected = false
            }
                
        }
        
    }
    
    func isValidEmailAddress(email: String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: email)

    }
    
    @IBAction func autoLoginSetValue(_ sender: UIButton) {
        //print(sender.isSelected)
        if sender.isSelected == true {
            UserDefaults.standard.set("notSelected", forKey: "isAutoLoginCheck");
            sender.isSelected = false
        }else {
            UserDefaults.standard.set("selected", forKey: "isAutoLoginCheck");
            sender.isSelected = true
            
        }
    }
    
    public func validatePassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[0-9])(?=.*[a-z]).{8,16}$"
            
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: password)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }

    @IBAction func actionMainButton(_ sender: Any) {
        //print("userLogin check..")
        // 로그인시 유효성 검사
        self.sv = UIViewController.displaySpinner(onView: self.view)
        guard let email = emailCheck.text, let password = passwordCheck.text else { return }
        let emailCheck = isValidEmailAddress(email: email)
        let passwordCheck = validatePassword(password: password)
        
        if !emailCheck {
            // 팝업 창 생성..
            let alert = UIAlertController(title: "로그인 실패", message: "이메일을 확인해주세요.", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler : nil)
            alert.addAction(defaultAction)
            
            
            present(alert, animated: false, completion: {
                    self.sv.removeFromSuperview()
            })
            
            return
        }
        
        if !passwordCheck {
            // 팝업 창 생성..
            let alert = UIAlertController(title: "로그인 실패", message: "비밀번호를 확인해주세요.", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler : nil)
            alert.addAction(defaultAction)
            
            
            present(alert, animated: false, completion: {
                    self.sv.removeFromSuperview()
            })
            
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {

                print(error?.localizedDescription as Any)
                print(error.debugDescription)
                let alert = UIAlertController(title: "로그인 실패", message: "아이디나 비밀번호를 확인해주세요.", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler : nil)
                alert.addAction(defaultAction)
                
                
                self.present(alert, animated: false, completion: {
                        self.sv.removeFromSuperview()
                })
                
                return
            } else {
                // 세션 유지 로그 아웃
                print("로그인 체크!")
                //print(user as Any)
                guard let user = user?.user else { return }
                //print(user.uid)
                UserDefaults.standard.set(user.uid, forKey: "UserKey") // UserKey Save
                UserDefaults.standard.set(email, forKey: "id")
                UserDefaults.standard.set(password, forKey: "pwd")
                self.emailCheck.text = ""
                self.passwordCheck.text = ""
                
                // 여기서 다음 화면으로 넘어아기
                // 모달 방식 에서 네비게이션 방식으로 수정하기
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "UITabBarVC") as! MainTabBarViewController
                storyboard.modalPresentationStyle = .fullScreen
                
                //self.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: {
                    self.sv.removeFromSuperview()
                })
            }
        }
        
        uid = ""
        pwd = ""
        myStage = ""
        self.sv.removeFromSuperview()
        
    }
    
    @IBAction func actionAccount(_ sender: Any) {
        uid = ""
        pwd = ""
        myStage = ""
        
    }
    
}

