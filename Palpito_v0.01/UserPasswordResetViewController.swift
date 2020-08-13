//
//  UserPasswordResetViewController.swift
//  Palpito
//
//  Created by 김정식 on 03/12/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserPasswordResetViewController: ExtensionVC {

    @IBOutlet weak var emailCheckTextFeled:UITextField?
    
    @IBOutlet weak var passwordResetView: UIView!
    
    var sv:UIView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / passwordResetView.bounds.width
        
        passwordResetView.transform = CGAffineTransform(scaleX: scale, y: scale)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func passwordResetfromEmailSendAction(){
        
        //self.sv = UIViewController.displaySpinner(onView: self.view)
        
        guard let emailcheck = self.emailCheckTextFeled?.text else {
            return
        }
        
        
        Auth.auth().sendPasswordReset(withEmail: emailcheck) { (err) in
            if err == nil {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewSb") as! ViewController
                storyboard.modalPresentationStyle = .fullScreen
                
                self.present(storyboard, animated: false, completion: {
                    // self.sv.removeFromSuperview()
                })
                
                
            }else {
                
            }
        }
        
    }
    
    //  확인 버튼
    // email input
    // email check 정규식 추가

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
