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
    
    weak var session:WCSession?
    
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
        
        let scale = view.bounds.width / myPageView.bounds.width
        
        myPageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // weak 처리
        healthKitShared.authorizeHealthKit { [weak self] (success, error) in
            //print("Was healthkit successful? \(success)")
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
        
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
            //print("session activate")
            if session!.isPaired != true {
                //print("Apple Watch is not paired")
            }else {
                //print("Apple Watch is paired")
                
            }
        } else {
            //print("session error")
        }
        
        let myStage = UserDefaults.standard.string(forKey: "myStage")
        
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
                    self.userNickName.text = nick_name
                }
                                
            }
        })
        
        if self.stageLevel != myStage {
            self.stageLevel = myStage!
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
            
        } else {
            stageLevelSendMsg = ["MyStageLvl":myStage] as! [String : String]
        }
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
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
        
//        do {
//            try session!.updateApplicationContext(stageLevelSendMsg)
//        } catch { }
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
        DispatchQueue.main.async {
            
            if let msg = message["MyStageLvl"] as? String {
                //print("userInfo message : \(msg)")
                UserDefaults.standard.set(msg, forKey: "myStage")
            
            }
            
            if let msg = message["StartWorkoutCall"] as? String {
                //print("message StartWorkoutCall : \(msg)")

                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
                self.resultTotalCalBurn.removeAll()
                self.resultTotalScore.removeAll()
                self.stageLevelSendMsg.removeAll()
                //self.session = nil
                
            } else if let msg = message["StartRelaxCall"] as? String {
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
            
            if let msg = userInfo["StartWorkoutCall"] as? String {
                    //print("userInfo StartWorkoutCall : \(msg)")

                    let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                    storyboard.modalPresentationStyle = .fullScreen
                    self.present(storyboard, animated: true, completion: nil)
                    
                    self.resultTotalCalBurn.removeAll()
                    self.resultTotalScore.removeAll()
                    self.stageLevelSendMsg.removeAll()
                    //self.session = nil
                    
                } else if let msg = userInfo["StartRelaxCall"] as? String {
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
