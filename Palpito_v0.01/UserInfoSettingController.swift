//
//  UserInfoSettingController.swift
//  Palpito
//
//  Created by 김정식 on 2020/07/25.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

// 유저 정보 수정 화면
class UserInfoSettingController: UIViewController {
    
    var db: Firestore!
    var genderVal:String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! // 고민해보기
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var userInfoSettingView: UIView!
    @IBOutlet weak var genderTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        db = Firestore.firestore()
                
        let datePickerView = UIDatePicker()
                
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(EmailAddViewController.onDatePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        datePickerView.locale = Locale(identifier: "ko_KR")
                
        birthTextField.inputView = datePickerView
                
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(EmailAddViewController.doneDatePickerPressed))
        // Do any additional setup after loading the view.
        toolBar.setItems([space,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
                
        birthTextField.inputAccessoryView = toolBar
        //self.view.addSubview(birthTextField)
        
                
        let scale = view.bounds.width / userInfoSettingView.bounds.width
                        
        userInfoSettingView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        selectUserInfo()
                
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func selectUserInfo(){
        
        let userKey =  Auth.auth().currentUser?.uid
        
        
        //print(userKey as Any)
        db.collection("user_info").whereField("user_info_key",isEqualTo: userKey!).getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("user_info start")
                for document in querySnapshot!.documents {
                    let oneDocument = document.data()
                    let nick_name = oneDocument["nick_name"] as? String
                    let birth_date = oneDocument["birth_date"] as? String
                    let gender = oneDocument["gender"] as? String
                    
                    self.nickNameTextField.text = nick_name
                    self.birthTextField.text = birth_date
                    self.emailTextField.text = Auth.auth().currentUser?.email
                    self.genderVal = gender
                    
                    if self.genderVal == "M" {
                        self.genderTextField.text = "남자"
                        
                    }else {
                        self.genderTextField.text = "여자"
                    }
                    
                }
                                
            }
        })
        
    }
    
    @IBAction func backWorkoutPageAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 이메일(고정), 닉네임(고정), 생년웡일(수정), 성별(고정)
    // 파이어베이스 수정하고, healthkit 정보 수정하기.
    //
    
    func userOneSelectAction(){
        
        let userId = Auth.auth().currentUser?.uid // 유저 키값 설정
        
        db.collection("user_info").whereField("uid",isEqualTo: userId! as String).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print(querySnapshot as Any)
            }
        }
            
    }
    
    @IBAction func userUpdateAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem
        
//        guard let email = emailTextField.text, let password = passwordTextField.text, let nickName = nickNameTextField.text, let birthText =  birthTextField.text, let gender = self.genderVal else { return }
//
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
//
//            guard let user = authResult?.user else { return }
//
//            if error == nil {
//                //print("user create ok!!")
//                let userID = user.uid
//
//                let data : [String : Any] = [
//                        "nick_name" :nickName,
//                        "birth_date" : birthText,
//                        "gender" : gender,
//                        "user_info_key" : userID
//
//                ]
//
//                // update 쿼리 찾아보기
//                self!.db.collection("user_info").document(userID).setData(data) { err in
//                    if let err = err {
//                        print("Error writing document: \(err)")
//                    } else {
//                        print("Document successfully written!")
//                        // 여기서 다음 화면으로 넘어아기
//                        let storyboard = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
//                        storyboard.modalPresentationStyle = .fullScreen
//                        //self.modalPresentationStyle = .fullScreen
//                        self!.present(storyboard, animated: true, completion: nil)
//                        self!.view.removeFromSuperview()
//                        //
//                    }
//                }
//
//            } else {
//                //print("no??")
//            }
//        }
        
    }
    
}
