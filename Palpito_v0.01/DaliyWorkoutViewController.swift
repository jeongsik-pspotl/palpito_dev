//
//  DaliyWorkoutViewController.swift
//  Palpito
//
//  Created by 김정식 on 19/02/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class DaliyWorkoutViewController: UIViewController, WCSessionDelegate {
    
    let healthKitShared = HealthKitSharedFunction.sharedInstance
    
    weak var session = WCSession.default
    
    var resultWorkoutArray = [ResultWorkOut]()
    var resultTotalCalBurn = [String]()
    var resultTotalScore = [String]()
    var resultTotalWorkoutTime = [String]()

    @IBOutlet weak var todayDateText: UILabel!
    @IBOutlet weak var totalBurnCalText: UILabel!
    @IBOutlet weak var totalScoreText: UILabel!
    @IBOutlet weak var daliyWorkoutView: UIView!
    @IBOutlet weak var restingHeartRateText: UILabel!
    @IBOutlet weak var totalWorkoutTimeHourText: UILabel!
    @IBOutlet weak var totalWorkoutTimeMinusText: UILabel!
    
    var totalcalBurnInt:Int = 0
    var todayScoreInt:Int = 0
    var totalWorkoutTimeHour:Int = 0
    var totalWorkoutTimeMinus:Int = 0
    var totalcalBurn = "0"
    var todayScoreVal = "0"
    var totalSescTime:Int = 0
    
    var toDate = Date()
    var returnRestingHeartRate:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / daliyWorkoutView.bounds.width
        
        daliyWorkoutView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        healthKitShared.authorizeHealthKit { [weak self] (success, error) in
            //print("Was healthkit successful? \(success)")
            if success == true {
                
                self?.healthKitShared.getRestHeartRate()
                
            }
            
        }
        
        sleep(UInt32(1.2))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let dateToVal = dateFormatter.string(from: toDate)
        
        // testing...
        let fetchRequest: NSFetchRequest<ResultWorkOut> = ResultWorkOut.fetchRequest()
        let predicate = NSPredicate(format: "todayDate == %@", dateToVal) // 오늘 날짜 조건
        
        fetchRequest.predicate = predicate
        
        do {
            
            let resultWorkoutStatus = try PersistenceService.context.fetch(fetchRequest)
            self.resultWorkoutArray = resultWorkoutStatus
            
            for result in resultWorkoutStatus as [NSManagedObject]
            {
                //print("resultworkout core data check... ")
                //print(result.value(forKey: "todayDate") as Any)
                
                resultTotalCalBurn.append(result.value(forKey: "totalcalBurn") as! String)
                resultTotalScore.append(result.value(forKey: "totalScore") as! String)
                resultTotalWorkoutTime.append(result.value(forKey: "totalWorkOutTime") as! String)
            }
            
            //print("resultWorkout Array data count check... :  \(self.resultWorkoutArray.count)")
            
            //            //print(stageLevel)
        } catch { }
        
        
        for totalCalBurnCount in 0..<resultTotalCalBurn.count
        {
//            totalcalBurnInt += Int(resultTotalCalBurn[totalCalBurnCount])!
//            totalBurnCalText.text = String(totalcalBurnInt)
        }
        
        for totalScoreCount in 0..<resultTotalScore.count
        {
            todayScoreInt += Int(resultTotalScore[totalScoreCount])!
            totalScoreText.text = String(todayScoreInt)
        }
        
        for totalWorkoutTime in 0..<resultTotalWorkoutTime.count
        {
            var secsTime:Int = 0
            let arrayResultTimeArray = resultTotalWorkoutTime[totalWorkoutTime].components(separatedBy: ":")
            
            if Int(arrayResultTimeArray[0]) != 0 {
                secsTime += Int(arrayResultTimeArray[0])! * 3600
            } else if Int(arrayResultTimeArray[1]) != 0  {
                secsTime += Int(arrayResultTimeArray[1])! * 60
            } else if Int(arrayResultTimeArray[2]) != 0  {
                secsTime += Int(arrayResultTimeArray[2])!
            }
            
            //총 시간 카운트 완료된 이후에 총 운동 시간 합산!
            let minutes: Int = (totalSescTime / 60) % 60
            let hour: Int = totalSescTime / 3600
            
            totalWorkoutTimeHourText.text = String(format: "%01d", hour)
            totalWorkoutTimeMinusText.text = String(format: "%02d", minutes)
        }
        
        
        if healthKitShared.mainRestingHeartRate != "" {
            restingHeartRateText.text = healthKitShared.mainRestingHeartRate
        }
        
        todayDateText.text = dateToVal
        
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
    }
    @IBAction func showGetReady3(_ sender: Any) {
        // 소스 코드 추가
        self.performSegue(withIdentifier: "showGetReady3", sender: self)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    
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
                //print("userInfo StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            } else if let msg = userInfo["StartRelaxCall"] as? String {
                //print("userInfo StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
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
