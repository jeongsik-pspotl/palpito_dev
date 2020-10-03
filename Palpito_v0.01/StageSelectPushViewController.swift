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
import FirebaseFirestoreSwift

class StageSelectPushViewController: UIViewController, WCSessionDelegate {

    weak var wcSession:WCSession?
    var stageLevel: String = ""
    
    var db: Firestore!
    
    @IBOutlet weak var stageLevel1Btn: DLRadioButton!
    @IBOutlet weak var stageLevel2Btn: DLRadioButton!
    @IBOutlet weak var stageLevel3Btn: DLRadioButton!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var stageSettingView: UIView!
    
    deinit {
        //print("deinit StageSelect View.... ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / stageSettingView.bounds.width
        
        stageSettingView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        //ref = Database.database().reference()
        
        db = Firestore.firestore()
        
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
        
        db.collection("user_info").whereField("user_info_key",isEqualTo: userKey!).getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //print("user_info start")
                for document in querySnapshot!.documents {
                    let oneDocument = document.data()
                    let nick_name = oneDocument["nick_name"] as? String
                    self.userNickName.text = nick_name
                }
                                
            }
        })
        
        //print("viewDidLoad??")
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
            if (message["StartWorkoutCall"] as? String) != nil {
                //print("message StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }else if (message["StartRelaxCall"] as? String) != nil {
                //print("message StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        DispatchQueue.main.async {
            if (userInfo["StartWorkoutCall"] as? String) != nil {
                ////print("userInfo StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            } else if (userInfo["StartRelaxCall"] as? String) != nil {
                ////print("userInfo StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    

}
