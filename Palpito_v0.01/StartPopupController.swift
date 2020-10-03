//
//  StartPopupController.swift
//  Palpito
//
//  Created by 김정식 on 2020/08/22.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity

class StartPopupController: UIViewController, WCSessionDelegate  {
    
    @IBOutlet weak var startPopupView: UIView!
    
    weak var session = WCSession.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / startPopupView.bounds.width
        
        startPopupView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
    }
    
    @IBAction func returnToMainPage(){
        self.performSegue(withIdentifier: "backToMainTabar2", sender: self)
        self.view.removeFromSuperview()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        
        if let msg = message["MyStageLvl"] as? String {
            //print("userInfo message : \(msg)")
            UserDefaults.standard.set(msg, forKey: "myStage")
        
        }
        
        DispatchQueue.main.async {
            if (message["StartWorkoutCall"] as? String) != nil {
                //print("message StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    @IBAction func showGetReady3(_ sender: Any) {
        // 소스 코드 추가
        self.performSegue(withIdentifier: "showGetReady3", sender: self)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        DispatchQueue.main.async {
            if (userInfo["StartWorkoutCall"] as? String) != nil {
                //print("userInfo StartWorkoutCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            } else if (userInfo["StartRelaxCall"] as? String) != nil {
                //print("userInfo StartRelaxCall : \(msg)")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    
}
