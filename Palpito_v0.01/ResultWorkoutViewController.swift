//
//  ResultWorkoutViewController.swift
//  Palpito
//
//  Created by 김정식 on 28/01/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestoreSwift

class ResultWorkoutViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var resultHeartRateText: UILabel!
    @IBOutlet weak var resultTotalCalText: UILabel!
    @IBOutlet weak var resultTotalTimeText: UILabel!
    @IBOutlet weak var resultTotalScoreText: UILabel!
    @IBOutlet weak var resultWorkoutView: UIView!
    @IBOutlet weak var resultTotalMeterText: UILabel!
    @IBOutlet weak var resultNowDateTimeText: UILabel!
    
    weak var session:WCSession?
    
    var resultWorkoutArray = [ResultWorkOut]()
    
    var ref : DatabaseReference! = Database.database().reference().child("user_exercise")
    var db : Firestore!
    
    let today = Date()
    let formatter = DateFormatter()
    var stageLevel = ""
    var resultSendToday:String = ""
    var avgHeartRate: String?
    var totalWorkOutTime: String?
    var totalcalBurn: String?
    var totalScore: String?
    var totalMeter: String?
    
    deinit {
        //print("deinit ResultWorkout...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / resultWorkoutView.bounds.width
        
        resultWorkoutView.transform = CGAffineTransform(scaleX: scale, y: scale)

        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
        } else {
            //print("session error")
        }
        
        db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.resultSendToday = dateFormatter.string(from: today)
        
        if let myStage = UserDefaults.standard.string(forKey: "myStage"){
            self.stageLevel = myStage
        }else {
            UserDefaults.standard.set("SL2" , forKey: "myStage")
            self.stageLevel = "SL2"
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ResultWorkOut")
        let fetchRequest: NSFetchRequest<ResultWorkOut> = ResultWorkOut.fetchRequest()
        let predicate = NSPredicate(format: "todayDate == %@", self.resultSendToday)
        
        formatter.dateFormat = "yyyy.MM.dd(E) a h시 mm분"
        let result = formatter.string(from: today)
        resultNowDateTimeText.text = result
        
        request.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        
        do {
            
            let status = try PersistenceService.context.fetch(request)
            let resultWorkoutStatus = try PersistenceService.context.fetch(fetchRequest)
            self.resultWorkoutArray = resultWorkoutStatus
            for data in status as! [NSManagedObject]
            {
//                stageLevel = (data.value(forKey: "userLevel") as? String)!
                avgHeartRate = data.value(forKey: "avgHeartRate") as? String
                totalWorkOutTime = data.value(forKey: "totalWorkOutTime") as? String
                totalcalBurn = data.value(forKey: "totalcalBurn") as? String
                totalScore = data.value(forKey: "totalScore") as? String
                totalMeter = data.value(forKey: "avgSpeedHour") as? String
                
            }
            
//            //print(avgHeartRate)
            if avgHeartRate != nil {
                self.resultHeartRateText.text = avgHeartRate
            }
            
            if totalcalBurn != nil {
                self.resultTotalCalText.text = totalcalBurn
            }
            
            if totalWorkOutTime != nil {
                self.resultTotalTimeText.text = totalWorkOutTime
            }
            
            if totalScore != nil {
                self.resultTotalScoreText.text = totalScore
            }
            
            if totalMeter != nil {
                self.resultTotalMeterText.text = totalMeter
            }
            
        } catch { }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
        } else {
            //print("viewWillAppear session error")
        }
        
        //        //print("animated check \(animated)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //session = nil
        ////print("load did viewWillDisappear??")
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //session = nil
        ////print("load did viewDidDisappear??")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backToMainTabBar" {
            
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        ////print("activationState : \(activationState)")
        ////print("session : \(session)")
        ////print("error \(error as Any)")
        if error != nil {
            Crashlytics.crashlytics().record(error: error!)
        }
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        ////print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        ////print("sessionDidBecomeInactive : \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }

    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        DispatchQueue.main.async {
            
            if let resultAvgHeartRateMsg = message["resultHeartRateVal"] as? String {
                ////print("message resultHeartRateVal : \(resultAvgHeartRateMsg)")
                self.resultHeartRateText.text = "\(resultAvgHeartRateMsg)"
            }

            if let kcalDataMsg = message["resultCalVal"] as? String {
                ////print("message resultCalVal : \(kcalDataMsg)")
                self.resultTotalCalText.text = "\(kcalDataMsg)"
            }

            if let timerDataMsg = message["resultEndTimeVal"] as? String {
                ////print("message resultEndTimeVal : \(timerDataMsg)")
                self.resultTotalTimeText.text = "\(timerDataMsg)"
            }

            if let resultTotalScoreMsg = message["resultScoreCountVal"] as? String {
                ////print("message resultScoreCountVal : \(resultTotalScoreMsg)")
                self.resultTotalScoreText.text = "\(resultTotalScoreMsg)"
            }
            
            if let resultTotalMeterMsg = message["resultMetersVal"] as? String {
                self.resultTotalMeterText.text = "\(resultTotalMeterMsg)"
                
                
            }
            
            if (message["backToMainTab"] as? String) != nil {
                replyHandler!(["result":"success"])
                // db insert 구간
//                let user_exercise_key:String = self.ref.childByAutoId().key as Any as! String // 수정해야함
//
//                let data : [String : Any] = [
//                    "uid" : Auth.auth().currentUser!.uid,
//                    "user_exercise_key" : user_exercise_key,
//                    "avg_heart_rate" : self.avgHeartRate!,
//                    "user_level" : self.stageLevel,
//                    "total_cal_burn" : self.totalcalBurn!,
//                    "result_total_score" : Int(self.totalScore!)! as Any , // 개선해야함.
//                    "exercise_date" : self.resultSendToday,
//                    "today_workout_count" : self.resultWorkoutArray.count + 1, // 중요
//                    "result_total_time" : self.totalWorkOutTime!,
//                    "result_send_today" : self.resultSendToday,
//                    "result_meters" : ""
//                ]
//
//                print("user exercise data check :   \(data)")
                
                // 이동해야함 운동 완료 화면으로
//                self.db.collection("user_exercise").document(user_exercise_key).setData(data) { err in
//                    if let err = err {
//                        print("Error writing document: \(err)")
//                    } else {
//                        // print("Document successfully written!")
//
//                    }
//                }
                
                self.performSegue(withIdentifier: "backToMainTabBar", sender: self)
                self.view.removeFromSuperview()
                //self.navigationController!.popToRootViewController(animated: true)
                ////print("message backToMainTab : \(msg)")
                
            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            
            if let resultAvgHeartRateMsg = userInfo["resultHeartRateVal"] as? String {
                ////print("message resultHeartRateVal : \(resultAvgHeartRateMsg)")
                self.resultHeartRateText.text = "\(resultAvgHeartRateMsg)"
            }

            if let kcalDataMsg = userInfo["resultCalVal"] as? String {
                ////print("message resultCalVal : \(kcalDataMsg)")
                self.resultTotalCalText.text = "\(kcalDataMsg)"
            }

            if let timerDataMsg = userInfo["resultEndTimeVal"] as? String {
                ////print("message resultEndTimeVal : \(timerDataMsg)")
                self.resultTotalTimeText.text = "\(timerDataMsg)"
            }

            if let resultTotalScoreMsg = userInfo["resultScoreCountVal"] as? String {
                ////print("message resultScoreCountVal : \(resultTotalScoreMsg)")
                self.resultTotalScoreText.text = "\(resultTotalScoreMsg)"
            }
            
            
            if let resultTotalMeterMsg = userInfo["resultMetersVal"] as? String {
                self.resultTotalMeterText.text = "\(resultTotalMeterMsg)"
                
                
            }
            // meter 값 추가해야함...
            
            if (userInfo["backToMainTab"] as? String) != nil {
                
                // db insert 구간
//                let user_exercise_key:String = self.ref.childByAutoId().key as Any as! String // 수정해야함
//
//                let data : [String : Any] = [
//                    "uid" : Auth.auth().currentUser!.uid,
//                    "user_exercise_key" : user_exercise_key,
//                    "avg_heart_rate" : self.avgHeartRate!,
//                    "user_level" : self.stageLevel,
//                    "total_cal_burn" : self.totalcalBurn!,
//                    "result_total_score" : Int(self.totalScore!)! as Any , // 개선해야함.
//                    "exercise_date" : self.resultSendToday,
//                    "today_workout_count" : self.resultWorkoutArray.count + 1, // 중요
//                    "result_total_time" : self.totalWorkOutTime!,
//                    "result_send_today" : self.resultSendToday,
//                    "result_meters" : ""
//                ]
                
                // 이동해야함 운동 완료 화면으로
//                self.db.collection("user_exercise").document(user_exercise_key).setData(data) { err in
//                    if let err = err {
//                        print("Error writing document: \(err)")
//                    } else {
//                        // print("Document successfully written!")
//
//                    }
//                }
                
                self.performSegue(withIdentifier: "backToMainTabBar", sender: self)
                self.view.removeFromSuperview()
                
            }
        
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
//        DispatchQueue.main.async {
//            print(file)
//
//            do {
//
//                // 29일에 해당 구간 좀 더 구현할 방법 찾아보기
//                //try fileManager.createDirectory(at: <#T##URL#>, withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[FileAttributeKey : Any]?#>)
//
//                let strText = try String(contentsOf: file.fileURL, encoding: .utf8)
//                print("test..")
//                print(strText)
//                
//            } catch let e {
//                print(e.localizedDescription)
//            }
//
//        }
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
