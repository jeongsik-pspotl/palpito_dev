//
//  ResultRelaxViewController.swift
//  Palpito
//
//  Created by 김정식 on 23/05/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData

class ResultRelaxViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var resultRelaxTotalTime: UILabel!
    @IBOutlet weak var resultRelaxHeartRateText: UILabel!
    @IBOutlet weak var resultRelaxView: UIView!
    
    weak var session:WCSession?
    
    var avgHeartRate: String?
    var totalRelaxTime: String?
    var todayDateVal:String?
    
    deinit {
        //print("deinit ResultRelax...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / resultRelaxView.bounds.width
        
        resultRelaxView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ResultRelax")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let status = try PersistenceService.context.fetch(request)
            for data in status as! [NSManagedObject]
            {
                avgHeartRate = data.value(forKey: "avgHeartRate") as? String
                totalRelaxTime = data.value(forKey: "totalRelaxTime") as? String
                todayDateVal = data.value(forKey: "todayDate") as? String
                
            }
            //print("result relax data check... ")
            //print("avgHeartRate : \(String(describing: avgHeartRate))")
            //print("totalRelaxTime : \(String(describing: totalRelaxTime))")
            //print("todayDateVal : \(String(describing: todayDateVal))")
            
            //  //print(avgHeartRate)
            if avgHeartRate != nil {
                self.resultRelaxHeartRateText.text = avgHeartRate
            }

            if totalRelaxTime != nil {
                self.resultRelaxTotalTime.text = totalRelaxTime
            }
            
        } catch { }

        // Do any additional setup after loading the view.
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
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
            
            if let msg = message["backToMainTab"] as? String {
                
                //backToMainTabBar
                let startAppSb: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
                let vc: UIViewController = startAppSb.instantiateViewController(withIdentifier: "UITabBarVC")
                vc.modalPresentationStyle = .fullScreen
                let window = UIApplication.shared.windows[0] as UIWindow
                UIView.transition(from: (window.rootViewController?.view)!, to: vc.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve) { [weak window] (finished) in
                    window?.rootViewController = vc
                }
                window.rootViewController = vc
                
                //print("message backToMainTab : \(msg)")
                
            }
            
            if let resultAvgHeartRateMsg = message["resultRelaxHeartRateVal"] as? String {
                //print("message resultRelaxHeartRateVal : \(resultAvgHeartRateMsg)")
                self.resultRelaxHeartRateText.text = "\(resultAvgHeartRateMsg)"
            }
            
            
            if let timerDataMsg = message["resultRelaxEndTimeVal"] as? String {
                //print("message resultRelaxEndTimeVal : \(timerDataMsg)")
                self.resultRelaxTotalTime.text = "\(timerDataMsg)"
            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let msg = userInfo["backToMainTab"] as? String {
                
                //backToMainTabBar
                let startAppSb: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
                let vc: UIViewController = startAppSb.instantiateViewController(withIdentifier: "UITabBarVC")
                vc.modalPresentationStyle = .fullScreen
                
                let window = UIApplication.shared.windows[0] as UIWindow
                UIView.transition(from: (window.rootViewController?.view)!, to: vc.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve) { [weak window] (finished) in
                    window?.rootViewController = vc
                }
                window.rootViewController = vc
                //print("userInfo backToMainTab : \(msg)")
                
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
