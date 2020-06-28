//
//  EmailAddViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 28/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EmailAddViewController: UIViewController, UITextFieldDelegate {
    
    var mUserCreate = UserCreate()
    var nextdata = UserInfo()
    weak var ref:DatabaseReference!
    var genderVal:String?
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var userCreateView: UIView!
    @IBOutlet weak var femaleRadioBtn: DLRadioButton!
    @IBOutlet weak var maleRadioBtn: DLRadioButton!
    
    
//    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
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
        self.genderVal = "F"
        
        let scale = view.bounds.width / userCreateView.bounds.width
                
        userCreateView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func userCreateAction(_ sender: UIButton){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let nickName = nickNameTextField.text, let birthText =  birthTextField.text, let gender = self.genderVal else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            
            guard let user = authResult?.user else { return }
            
            if error == nil {
                //print("user create ok!!")
                let userID = user.uid
                self!.ref.child("user_info/\(userID)/nick_name").setValue(nickName)
                self!.ref.child("user_info/\(userID)/birth_date").setValue(birthText)
                self!.ref.child("user_info/\(userID)/gender").setValue(gender)
                self!.ref.child("user_info/\(userID)/user_info_key").setValue(userID) // test 필요...
                
                // 여기서 다음 화면으로 넘어아기
                let storyboard = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
                storyboard.modalPresentationStyle = .fullScreen
                //self.modalPresentationStyle = .fullScreen
                self!.present(storyboard, animated: true, completion: nil)
                
            } else {
                //print("no??")
            }
        }
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem
//
//        guard let email = emailTextField.text, let password = passwordTextField.text, let nickName = nickNameTextField.text, let birthText =  birthTextField.text, let gender = self.genderVal else { return }
//
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//
//            guard let user = authResult?.user else { return }
//
//            if error == nil {
//                //print("user create ok!!")
//                let userID = user.uid
//                self.ref.child("user_info/\(userID)/nick_name").setValue(nickName)
//                self.ref.child("user_info/\(userID)/birth_date").setValue(birthText)
//                self.ref.child("user_info/\(userID)/gender").setValue(gender)
//
//                self.nextdata.name = nickName // 닉네임 세팅
//
//            } else {
//
//            }
//        }
//
//        // 처리 완료 되면
//        // func 내부 처리 구간으로 보내기
//        // if segue.identifier == "nextUserCreate" {
//        //    (segue.destination as! PopUpViewController).beforeCreateUserData = nextdata
//        // }
//    }
    
    @IBAction func femaleRadioBtnAction(_ sender: DLRadioButton){
        if sender.tag == 1 {
            self.genderVal = "F"
            
        }
    }
    
    @IBAction func maleRadioBtnAction(_ sender: DLRadioButton){
        if sender.tag == 2 {
            self.genderVal = "M"
        }
        
    }
    
    @IBAction func passwordInfoAction(_ sender: UIButton) {
        //print("start sender.isSelected : \(//print(sender.isSelected))")
        if sender.isSelected {
            passwordTextField.isSecureTextEntry = true
            sender.isSelected = false
        }else{
            passwordTextField.isSecureTextEntry = false
            sender.isSelected = true
        }
        //print("end sender.isSelected : \(//print(sender.isSelected))")
    }
    
    @IBAction func emailCheckAction(_ sender: UIButton) {
        var emailCheckVar = ""
        let dialogMessage = UIAlertController(title: "이메일 체크", message: "이메일 중복 확인 되었습니다", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            //print("test ok!!")
        }
        
        dialogMessage.addAction(ok)
        
        if emailTextField.text == nil {
            
        }else{
            emailCheckVar = emailTextField.text!
        }
        
        let param: [String: Any] = ["email": emailCheckVar]
        
        guard let paramData = try? JSONSerialization.data(withJSONObject: param, options: []) else {
            return
        }
        
        guard let url = URL(string: "http://192.168.0.30:3000/emailCheck_process") else{
            //print("Error: cannot create URL")
            return
            
        }
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    @objc func onDatePickerValueChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
//        //print("\(dateFormatter.string(from: sender.date))")
        self.birthTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneDatePickerPressed(){
        self.view.endEditing(true)
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        
        if sender.isSelected {
            
            sender.isSelected = false
        }else{
            
            sender.isSelected = true
        }
    }
    
    func onPostCreateUesr(userData:UserInfo){
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let stringDate = dateFormatter.string(from: date)
        
        //print(stringDate)
        //print("userData  = \(userData)")
        
        let param: [String: Any] = ["email": (userData.email)!
            ,"name": (userData.name)!
            ,"password": (userData.password)!
            ,"age": (userData.birth)!
            ,"gender": (userData.gender)!
            ,"user_level": "SL1"
            ]
        
        let paramData = try! JSONSerialization.data(withJSONObject: param, options: [])
        
        guard let url = URL(string: "http://192.168.0.30:3000/create_process") else{
            //print("Error: cannot create URL")
            return
            
        }
        
        // 3. URLRequest 객체 정의 및 요청 내용 담기
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        // 4. HTTP 메시지에 포함될 헤더 설정
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
        
        // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if response != nil {
             //print(response)
            }
            guard let data = data, error == nil else {
                //print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJson = responseJson as? [String: Any] {
                
                let status = responseJson["status"] as? String
                //                //print("json.2 \(responseJson)")
                if let actualStatus = status {
                    //print("json status \(actualStatus)")
                    
                }
                
            }
            
        })
        // post 전송
        task.resume()
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
