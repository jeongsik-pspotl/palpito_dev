//
//  StandByWorkoutInterfaceController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 11/01/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class StandByWorkoutInterfaceController: WKInterfaceController, WCSessionDelegate {

    weak var wcSession:WCSession?
    var myStageLevelData: String = "SL1"
    
    var launchWatchAppVal:String?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("1")
        // 여기서 강도 설정 값을 받을지..
        
//        WCSession.deac
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            
            //wcSession?.di
            //wcSession?.dele
            //print("session \(String(describing: wcSession?.activationState.rawValue))")
            //print("session activate")
        } else {
            //print("session error")
        }
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            //wcSession?.finalize()
            //print("session \(String(describing: wcSession?.activationState.rawValue))")
            //print("session activate")
        } else {
            //print("session error")
        }
        
        // 여기서 강도 설정 값을 받을지..
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("session \(session) activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // 백그라운드 처리 전환 작업 소스 시작 지점
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let msg = userInfo["MyStageLvl"] as? String {
                //print("userInfo MyStageLvl : \(msg)")
                self.myStageLevelData = "\(msg)"
            }
            
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        handlesSession(session, didReceiveMessage: message)

    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {

        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)

    }

    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        DispatchQueue.main.async {
            if let myStageLvl = message["MyStageLvl"] {
                //print(" data check : \(myStageLvl)")
                self.myStageLevelData = myStageLvl as! String
            }
            
        }

    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        if let context = applicationContext["MyStageLvl"] {
            //print(" context check : \(context)")
            self.myStageLevelData = context as! String
        }
        
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // 운동 화면으로 이동
    func workoutSendMainInterface(MyStageLvl: String){
        
        var context:[String:String]?
        context = ["MyStageLvl": MyStageLvl]
        
        var startWorkoutSendData = ["StartWorkoutCall":"true","MyStageLvl": MyStageLvl]
        
        if(wcSession?.isReachable == true){
            
            tryWatchSendMessage(message: startWorkoutSendData as [String : Any])
        }
        
        
        // 아이폰 통신 구간.. waek self memory leak 구간
        pushController(withName: "MainInterfaceController", context: context)
        
        startWorkoutSendData.removeAll()
        //context?.removeAll()
    }
    
    // SL3
    @IBAction func workoutOutdoorStart() {
        //print("workoutOutdoorStart action ?? ")
        
        workoutSendMainInterface(MyStageLvl: "SL3")

    }
    
    // SL2
    @IBAction func workoutOutdoorMidStart() {
        //print("workoutOutdoorStart action ?? ")
        
        workoutSendMainInterface(MyStageLvl: "SL2")
        
    }
    
    // SL1
    @IBAction func workoutOutdoorLowStart() {
        //print("workoutOutdoorStart action ?? ")
        
        workoutSendMainInterface(MyStageLvl: "SL1")
        
    }
    
    
    @IBAction func relaxStartAction() {
        //print("MainRelaxInterfaceController action ?? ")
        
//        var context:[String:String]?
//        context = ["MyStageLvl": myStageLevelData]
        
        var startRelaxSendData:[String:String]?
        startRelaxSendData = ["StartRelaxCall":"true"]
        
        tryWatchSendMessage(message: startRelaxSendData! as [String : Any])
        //wcSession?.sendMessage(startRelaxSendData!, replyHandler: nil, errorHandler: nil)
        //wcSession?.transferUserInfo(startRelaxSendData!)
        
        // 아이폰 통신 구간.. waek self memory leak 구간
        pushController(withName: "MainRelaxInterfaceController", context: nil)
        
        startRelaxSendData?.removeAll()
//        context?.removeAll()
    }
    
    
    func tryWatchSendMessage(message: [String : Any]) {
        
            if #available(watchOSApplicationExtension 6.0, *) {
             if self.wcSession != nil && self.wcSession?.activationState == .activated {
                    if self.wcSession?.isReachable == true {
                        self.wcSession?.sendMessage(message, replyHandler: nil) { (error) -> Void in
                            // If the message failed to send, queue it up for future transfer
                            //print(" StandByWorkoutInterfaceController error : \(error)")
                            self.wcSession?.transferUserInfo(message)
                        }
                    }
             } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                 self.wcSession?.transferUserInfo(message)
             }
            } else {
                
             // Fallback on earlier versions
             if self.wcSession != nil && self.wcSession?.activationState == .activated {
                    if self.wcSession?.isReachable == true {
                        self.wcSession?.sendMessage(message, replyHandler: nil) { (error) -> Void in
                            //print(" StandByWorkoutInterfaceController error : \(error)")
                                       // If the message failed to send, queue it up for future transfer
                                       //self.wcSession?.transferUserInfo(message)
                            }
                    } else {
                        self.wcSession?.transferUserInfo(message)
                    }
                } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                    self.wcSession?.transferUserInfo(message)
                }
            }
           
    }
    
}
