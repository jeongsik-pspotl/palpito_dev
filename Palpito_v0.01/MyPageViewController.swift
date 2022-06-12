//
//  MyPageViewController.swift
//  Palpito
//
//  Created by 김정식 on 30/01/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI
import CoreData
import WatchConnectivity
import Firebase
import FirebaseFirestoreSwift
import FirebaseCrashlytics

class MyPageViewController: UIViewController, WCSessionDelegate {
    
    let healthKitShared = HealthKitSharedFunction.sharedInstance
    var db: Firestore!
    
    var toDate = Date()

    var resultTotalCalBurn = [String]()
    var resultTotalScore = [String]()
    var stageLevel = ""
    var stageLevelSendMsg = [String:String]()
    
    var totalcalBurnInt:Int = 0
    var todayScoreInt:Int = 0
    var totalcalBurn = "0"
    var todayScoreVal = "0"
    
    weak var wcSession:WCSession?
    
    @IBOutlet weak var myStageLevelButton: UIButton!
    @IBOutlet weak var todayScoreText: UILabel!
    @IBOutlet weak var avgHeartRateText: UILabel!
    @IBOutlet weak var toDayActivityEnergyBurnedGoal: UILabel!
    @IBOutlet weak var myPageView: UIView!
    @IBOutlet weak var userNickName: UILabel!
    
    deinit {
        //print("deinit mypage")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Locale.current.regionCode
        //print("Locale.current.languageCode")
        //print(Locale.current.languageCode)
        
        
        let scale = view.bounds.width / myPageView.bounds.width
        
        myPageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            
            //print("session activate")
            if wcSession!.isPaired != true {
                //print("Apple Watch is not paired")
            }else {
                //print("Apple Watch is paired")
                
            }
        } else {
            //print("session error")
        }
        
        let data: [String: Any] = ["logincheck": "Yes" ]
        
        tryWatchSendMessage(message: data)
        
        // weak 처리
        healthKitShared.authorizeHealthKit { [weak self] (success, error) in
            print("Was healthkit successful? \(success)")
            if success == true {
                
//                self?.healthKitShared.readMostRecentSample()
                self?.healthKitShared.readTodayAvgHeartRate()
                self?.healthKitShared.getActivitySummaryEnergyBurnedGoal()
                

            }
            
        }
        sleep(UInt32(1.2))
        
        db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let dateToVal = dateFormatter.string(from: toDate)
        
        // testing...
        let fetchRequest: NSFetchRequest<ResultWorkOut> = ResultWorkOut.fetchRequest()
        let predicate = NSPredicate(format: "todayDate == %@", dateToVal) // 오늘 날짜 조건
        
        fetchRequest.predicate = predicate
        
        do {
            
            let resultWorkoutStatus = try PersistenceService.context.fetch(fetchRequest)
            for result in resultWorkoutStatus as [NSManagedObject]
            {
//                resultTotalCalBurn.append(result.value(forKey: "totalcalBurn") as! String)
                resultTotalScore.append(result.value(forKey: "totalScore") as! String)
            }

        } catch { }
        
        // coredata 에 들어가 있어서 나중에 수정해야함.
//        for totalCalBurnCount in 0..<resultTotalCalBurn.count
//        {
//            totalcalBurnInt += Int(resultTotalCalBurn[totalCalBurnCount])!
//            toDayActivityEnergyBurnedGoal.text = String(totalcalBurnInt)
//        }
        
        for totalScoreCount in 0..<resultTotalScore.count
        {
            todayScoreInt += Int(resultTotalScore[totalScoreCount])!
            todayScoreText.text = String(todayScoreInt)
        }
        
        if self.healthKitShared.todayActiveEnergyBurned != ""{
            toDayActivityEnergyBurnedGoal.text = self.healthKitShared.todayActiveEnergyBurned
        }
        
        
        if self.healthKitShared.todayAvgHeartRate != "" {
            avgHeartRateText.text = self.healthKitShared.todayAvgHeartRate
        }
        
        
        
        
        let myStage = UserDefaults.standard.string(forKey: "myStage")
        
        let userKey =  Auth.auth().currentUser?.uid
        //print(userKey as Any)
        db.collection("user_info").whereField("user_info_key",isEqualTo: userKey!).getDocuments(completion: { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // print("user_info start")
                for document in querySnapshot!.documents {
                    let oneDocument = document.data()
                    let nick_name = oneDocument["nick_name"] as? String
                    self.userNickName.text = nick_name
                }
                
                let data: [String: Any] = ["logincheck": "Yes" as String]
                
                UserDefaults.standard.set("Yes" , forKey: "logincheck")
//                /print("login check data :  \(data)")
                tryWatchSendMessage(message: data)
                
                do {
                    try wcSession?.updateApplicationContext(data)
                } catch { }
                                
            }
        })
        
        if self.stageLevel != myStage {
            self.stageLevel = myStage!
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
            
        } else {
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
        }
        
    }
    
//    @IBAction func crashButtonTapped(_ sender: AnyObject) {
//        Crashlytics.crashlytics().setCustomValue("hello", forKey: "str_key")
//        fatalError("test")
//        //fatalError()
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
        let myStage = UserDefaults.standard.string(forKey: "myStage")
        
        //print("setting start stageLevel : \(myStage!)")
        
        if self.stageLevel != myStage {
            self.stageLevel = myStage!
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
            
        } else {
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
        }
        
        
        let data: [String: Any] = ["logincheck": "Yes" as String]
        UserDefaults.standard.set("Yes" , forKey: "logincheck")
        
        tryWatchSendMessage(message: data)
        //tryWatchSendMessage(message: data)
        do {
            try wcSession?.updateApplicationContext(data)
        } catch { }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //print("load did appear??")
        let storyBoard: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "StartPopup") as! StartPopupController
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //session = nil
        //print("load did viewWillDisappear??")
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //session = nil
        //print("load did viewDidDisappear??")
    }
    
    @IBAction func onMyStageSettingAction() {
        performSegue(withIdentifier: "showStageLevel", sender: self)
        
    }
    
    @IBAction func onGetReadyAction(_ sender: Any) {
        performSegue(withIdentifier: "showGetReady", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStageLevel" {
//            let secondVC = segue.destination as! StageSelectPushViewController
//            secondVC.delegate = self
//            secondVC.providesPresentationContextTransitionStyle = true
//            secondVC.definesPresentationContext = true
//            secondVC.modalPresentationStyle = .overCurrentContext
            
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("activationState : \(activationState)")
        //print("session : \(session)")
        //print("error \(error as Any)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //print("sessionDidBecomeInactive : \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        DispatchQueue.main.async { [self] in
            
            if let msg = message["MyStageLvl"] as? String {
                //print("userInfo message : \(msg)")
                UserDefaults.standard.set(msg, forKey: "myStage")
            
            }
            
            if let loginMessage = message["logincheck"] as? String {
                //print("\(loginMessage)")
                if loginMessage == "No" {
                    let loginUserData = UserDefaults.standard.string(forKey: "logincheck")
                    
                    let data: [String: Any] = ["logincheck": loginUserData! as String]
                    self.tryWatchSendMessage(message: data)
                }
            }
            
            if (message["StartWorkoutCall"] as? String) != nil {
                //print("message StartWorkoutCall : \(msg)")
                // replyHandler!(["result":"success"])
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
                self.resultTotalCalBurn.removeAll()
                self.resultTotalScore.removeAll()
                self.stageLevelSendMsg.removeAll()
                //self.session = nil
                
            } else if (message["StartRelaxCall"] as? String) != nil {
                //print("message StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
                self.resultTotalCalBurn.removeAll()
                self.resultTotalScore.removeAll()
                self.stageLevelSendMsg.removeAll()
                //self.session = nil
                
            }
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            
            if let msg = userInfo["MyStageLvl"] as? String {
                //print("userInfo MyStageLvl : \(msg)")
                
                UserDefaults.standard.set(msg, forKey: "myStage")
            
            }
            
            if let loginMessage = userInfo["logincheck"] as? String {
                //print("\(loginMessage)")
                if loginMessage == "No" {
                    let loginUserData = UserDefaults.standard.string(forKey: "logincheck")
                    
                    let data: [String: Any] = ["logincheck": loginUserData! as String]
                    self.tryWatchSendMessage(message: data)
                }
            }
            
            if (userInfo["StartWorkoutCall"] as? String) != nil {
                    //print("userInfo StartWorkoutCall : \(msg)")

                    let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                    storyboard.modalPresentationStyle = .fullScreen
                    self.present(storyboard, animated: true, completion: nil)
                    
                    self.resultTotalCalBurn.removeAll()
                    self.resultTotalScore.removeAll()
                    self.stageLevelSendMsg.removeAll()
                    //self.session = nil
                    
            } else if (userInfo["StartRelaxCall"] as? String) != nil {
                    //print("userInfo StartRelaxCall : \(msg)")
                    
                    let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                    self.present(storyboard, animated: true, completion: nil)
                    
                    self.resultTotalCalBurn.removeAll()
                    self.resultTotalScore.removeAll()
                    self.stageLevelSendMsg.removeAll()
                    //self.session = nil
                    
            }
            
        }
            
    }
    
//    func session(_ session: WCSession, didReceive file: WCSessionFile) {
//        DispatchQueue.main.async {
//
//            do {
//                print(file)
//                // 29일에 해당 구간 좀 더 구현할 방법 찾아보기
//                // try fileManager.createDirectory(at: <#T##URL#>, withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[FileAttributeKey : Any]?#>)
//
//                let strText = try String(contentsOf: file.fileURL, encoding: .utf8)
//
//                print(strText)
//
//            } catch let e {
//                print(e.localizedDescription)
//            }
//
//        }
//    }
    
    func tryWatchSendMessage(message: [String : Any]) {
        
//        if let validSession = self.wcSession {
//            //let data: [String: Any] = ["logincheck": "No" as Any]
//            //UserDefaults.standard.set("No" , forKey: "logincheck")
//            validSession.transferUserInfo(message)
//
//        }
//
//        if self.wcSession != nil && self.wcSession?.activationState == .activated {
//            if self.wcSession?.isReachable == true {
//                self.wcSession?.sendMessage(message, replyHandler: nil) { (error) -> Void in
//                             // If the message failed to send, queue it up for future transfer
//                             print(" StandByWorkoutInterfaceController error : \(error)")
//                             self.wcSession?.transferUserInfo(message)
//                }
//            }
//        }
        
        if WCSession.isSupported() {
             if self.wcSession != nil && self.wcSession?.activationState == .activated {
                    if self.wcSession?.isReachable == true {
                        //replyHandler in 응답이 정상인 구간일 경우 다음 화면으로 넘어가는 기능을 구현해야함.
                        self.wcSession?.sendMessage(message, replyHandler: { (reply: [String : Any]) -> Void in
                            //guard let result = reply["result"] else { return }
                            //print("test reply result")
                            //print(result)
                            self.wcSession?.transferUserInfo(message)
                            
                        }) { (error) -> Void in
                            // If the message failed to send, queue it up for future transfer
                            print(" StandByWorkoutInterfaceController error : \(error)")
                            self.wcSession?.transferUserInfo(message)
                            
                        }
                    }
             } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                 self.wcSession?.transferUserInfo(message)
             }else {
                self.wcSession?.transferUserInfo(message)
             }
        }else {
            self.wcSession?.transferUserInfo(message)
        }
        
            
    }
    
//    func dataReceived(data: String) {
//
//        if data == "SL1" {
//            myStageLevelButton.setImage(UIImage(named: "myStage1"), for: .normal)
//        } else if data == "SL2" {
//            myStageLevelButton.setImage(UIImage(named: "myStage2"), for: .normal)
//        } else if data == "SL3" {
//            myStageLevelButton.setImage(UIImage(named: "myStage3"), for: .normal)
//        }
//
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
