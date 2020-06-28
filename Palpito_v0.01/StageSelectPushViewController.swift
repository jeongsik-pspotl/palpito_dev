//
//  StageSelectPushViewController.swift
//  Palpito
//
//  Created by 김정식 on 07/02/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity
import Firebase
import FirebaseDatabase

class StageSelectPushViewController: UIViewController, WCSessionDelegate {

    weak var wcSession:WCSession?
    var stageLevel: String = ""
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var stageLevel1Btn: DLRadioButton!
    @IBOutlet weak var stageLevel2Btn: DLRadioButton!
    @IBOutlet weak var stageLevel3Btn: DLRadioButton!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var stageSettingView: UIView!
    
    deinit {
        ////print("deinit StageSelect View.... ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / stageSettingView.bounds.width
        
        stageSettingView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        ref = Database.database().reference()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            ////print("session activate")
        } else {
            //print("session error")
        }
        
        if let myStage = UserDefaults.standard.string(forKey: "myStage"){
            self.stageLevel = myStage
            
        }
        
        if stageLevel == "SL1" {
            stageLevel1Btn.isSelected = true

        } else if stageLevel == "SL2" {
            stageLevel2Btn.isSelected = true

        } else if stageLevel == "SL3" {
            stageLevel3Btn.isSelected = true

        } else {
            stageLevel1Btn.isSelected = true

        }
        
        let userKey =  Auth.auth().currentUser?.uid
        //print(userKey as Any)
               
        self.ref.child("user_info").child(userKey!).observeSingleEvent(of: .value, with: { (snapshot) in
                 // Get user value
                 let value = snapshot.value as? NSDictionary
                 let nick_name = value?["nick_name"] as? String ?? ""
                 self.userNickName.text = nick_name
                 
            }) { (error) in
                //print(error.localizedDescription)
        }
        
        ////print("viewDidLoad??")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            ////print("session activate")
        } else {
            //print("session error")
        }
        
        if let myStage = UserDefaults.standard.string(forKey: "myStage"){
            self.stageLevel = myStage
            
        }
        
        if stageLevel == "SL1" {
            stageLevel1Btn.isSelected = true

        } else if stageLevel == "SL2" {
            stageLevel2Btn.isSelected = true

        } else if stageLevel == "SL3" {
            stageLevel3Btn.isSelected = true

        } else {
            stageLevel1Btn.isSelected = true

        }
        
        ////print("viewWillAppear??")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
//        let startAppSb: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
//        let vc: UIViewController = startAppSb.instantiateViewController(withIdentifier: "UITabBarVC")
//        vc.modalPresentationStyle = .fullScreen
//
//        let window = UIApplication.shared.windows[0] as UIWindow
//        UIView.transition(from: (window.rootViewController?.view)!, to: vc.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve) { [weak window] (finished) in
//            window?.rootViewController = vc
//        }
//        window.rootViewController = vc
        if let navigationController = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController) {
            
            navigationController.popToRootViewController(animated: true)
            
        }
        //wcSession = nil
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //wcSession = nil
        
        ////print("load did viewWillDisappear??")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stageLevel1Action(_ sender: DLRadioButton) {
        
        if sender.tag == 1 {
            let myStageSettingInt = "SL1"
            sendMyPageStageLevel(myStageSetting: myStageSettingInt)
            
        }
        
        
    }

    @IBAction func showGetReady2(_ sender: Any) {
        // 소스 코드 추가
        self.performSegue(withIdentifier: "showGetReady2", sender: self)
    }
    
    @IBAction func stageLevel2Action(_ sender: DLRadioButton) {
        
        if sender.tag == 2 {
            let myStageSettingInt = "SL2"
            sendMyPageStageLevel(myStageSetting: myStageSettingInt)
            
        }
        
    }
    
    @IBAction func stageLevel3Action(_ sender: DLRadioButton) {
        
        if sender.tag == 3 {
            let myStageSettingInt = "SL3"
            sendMyPageStageLevel(myStageSetting: myStageSettingInt)
            
        }
        
    }
    
    func sendMyPageStageLevel(myStageSetting: String) {
        // MyStage 제거 및 수정 get set
//        let MyStage = NSEntityDescription.entity(forEntityName: "MyStage", in: PersistenceService.context)
//        let newEntity = NSManagedObject(entity: MyStage!, insertInto: PersistenceService.context)
        var stageLevelSendMsg = [String:String]()
        
        if myStageSetting == "SL1" {

            stageLevelSendMsg = ["MyStageLvl":"SL1"]
            
        } else if myStageSetting == "SL2" {

            stageLevelSendMsg = ["MyStageLvl":"SL2"]
            
        } else if myStageSetting == "SL3" {

            stageLevelSendMsg = ["MyStageLvl":"SL3"]
            
        }
        
        // 운동 강도 설정
        UserDefaults.standard.set(myStageSetting, forKey: "myStage")
        
//        newEntity.setValue(myStageSetting, forKey: "stage")
//        PersistenceService.saveContext()
        
        // 백그라운드 처리 전환 소스 시작 지점
//        wcSession?.transferUserInfo(stageLevelSendMsg)
        
//        do {
//            try wcSession?.updateApplicationContext(stageLevelSendMsg)
//        } catch { }
        
        stageLevelSendMsg.removeAll()
        
        stageSettingView.removeFromSuperview()
        stageSettingView = nil
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        ////print("activationState : \(activationState)")
        ////print("session : \(session)")
        ////print("error \(error as Any)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        ////print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        ////print("sessionDidDeactivate : \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        
        DispatchQueue.main.async {
            if let msg = message["StartWorkoutCall"] as? String {
                //print("message StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }else if let msg = message["StartRelaxCall"] as? String {
                //print("message StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        DispatchQueue.main.async {
            if let msg = userInfo["StartWorkoutCall"] as? String {
                ////print("userInfo StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            } else if let msg = userInfo["StartRelaxCall"] as? String {
                ////print("userInfo StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    

}
