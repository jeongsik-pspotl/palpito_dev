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

class ResultWorkoutViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var resultHeartRateText: UILabel!
    @IBOutlet weak var resultTotalCalText: UILabel!
    @IBOutlet weak var resultTotalTimeText: UILabel!
    @IBOutlet weak var resultTotalScoreText: UILabel!
    @IBOutlet weak var resultWorkoutView: UIView!
    
    weak var session:WCSession?
    
    var stageLevel = ""
    var avgHeartRate: String?
    var totalWorkOutTime: String?
    var totalcalBurn: String?
    var totalScore: String?
    
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
            
            ////print("session activate")
        } else {
            //print("session error")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ResultWorkOut")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let status = try PersistenceService.context.fetch(request)
            for data in status as! [NSManagedObject]
            {
                avgHeartRate = data.value(forKey: "avgHeartRate") as? String
                totalWorkOutTime = data.value(forKey: "totalWorkOutTime") as? String
                totalcalBurn = data.value(forKey: "totalcalBurn") as? String
                totalScore = data.value(forKey: "totalScore") as? String
                
            }
            
//            //print(avgHeartRate)
            if avgHeartRate != nil {
                self.resultHeartRateText.text = avgHeartRate
            }
            
            if totalScore != nil {
                self.resultTotalCalText.text = totalcalBurn
            }
            
            if totalWorkOutTime != nil {
                self.resultTotalTimeText.text = totalWorkOutTime
            }
            
            if totalScore != nil {
                self.resultTotalScoreText.text = totalScore
            }
            
        } catch { }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
            ////print("viewWillAppear session activate")
        } else {
            //print("viewWillAppear session error")
        }
        
        //        //print("animated check \(animated)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ////print("load did appear??")
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
            
            if let msg = message["backToMainTab"] as? String {
                
                //backToMainTabBar
//                let startAppSb: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
//                let vc: UIViewController = startAppSb.instantiateViewController(withIdentifier: "UITabBarVC")
//                vc.modalPresentationStyle = .fullScreen
//                vc.loadView()
//
//                let window = UIApplication.shared.windows[0] as UIWindow
//                UIView.transition(from: (window.rootViewController?.view)!, to: vc.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve) { [weak window] (finished) in
//                    window?.rootViewController = vc
//                }
//                window.rootViewController = vc
                
                //self.resultWorkoutView.removeFromSuperview()
                //self.resultWorkoutView = nil
                //self.presentingViewController?.dismiss(animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backToMainTabBar", sender: self)
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
            
            if let msg = userInfo["backToMainTab"] as? String {
                
                //backToMainTabBar
//                let startAppSb: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
//                let vc: UIViewController = startAppSb.instantiateViewController(withIdentifier: "UITabBarVC")
//                vc.modalPresentationStyle = .fullScreen
//                vc.loadView()
//
//                let window = UIApplication.shared.windows[0] as UIWindow
//                UIView.transition(from: (window.rootViewController?.view)!, to: vc.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve) { [weak window] (finished) in
//                    window?.rootViewController = vc
//                }
//                window.rootViewController = vc
                
                //self.presentingViewController?.dismiss(animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backToMainTabBar", sender: self)
                //self.navigationController!.popToRootViewController(animated: true)
                ////print("userInfo backToMainTab : \(msg)")
                
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
