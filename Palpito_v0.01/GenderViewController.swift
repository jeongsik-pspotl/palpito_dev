//
//  GenderViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 28/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit

class GenderViewController: UIViewController {
    
    var mUserCreate = UserCreate()
    var beforeCreateUserData = UserInfo()
    
    
    @IBAction func createAction(_ sender: Any) {
        
    }
    @IBAction func genderButton(_ sender: DLRadioButton) {
        if sender.tag == 1{
            //print("남")
            beforeCreateUserData.gender = "M"
        }else if sender.tag == 2{
            //print("여")
            beforeCreateUserData.gender = "F"
        }
        //print("gender data check... \(beforeCreateUserData)")
        onPostCreateUesr(userData:beforeCreateUserData)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("UserInfo data call check .... :  \(beforeCreateUserData)")
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        beforeNameData.age = mUserCreate.ageAdd(age: Int(ageTextField.text!)!)!
//        //print(" check data :  \(beforeNameData)")
//        if segue.identifier == "nextUserGender" {
//            (segue.destination as! GenderViewController).beforeAgeData = beforeNameData
//        }
    }
    
    func onPostCreateUesr(userData:UserInfo){
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let stringDate = dateFormatter.string(from: date) 
        
        //print(stringDate)
        //print("userData  = \(userData)")
        
        let param: [String: Any] = ["email": (userData.email)!
            ,"nickName": (userData.name)!
            ,"password": (userData.password)!
            ,"age": (userData.birth)!
            ,"gender": (userData.gender)!
            ]
        
        let paramData = try! JSONSerialization.data(withJSONObject: param, options: [])
        
        guard let url = URL(string: "http://54.180.26.18:3000/create_process") else{
            //print("Error: cannot create URL")
            return
            
        }
        
        // 3. URLRequest 객체 정의 및 요청 내용 담기
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        // 4. HTTP 메시지에 포함될 헤더 설정
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //        request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
        
        // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            //            //print(response!)
            if let response = response {
                //                //print(response)
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
