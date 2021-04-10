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
import HealthKit


class StandByWorkoutInterfaceController: WKInterfaceController, WCSessionDelegate {

    weak var wcSession:WCSession?
    var myStageLevelData: String = "SL1"
    
    
    var launchWatchAppVal:String?
    
    let healthStore = HKHealthStore()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("1")
        // 여기서 강도 설정 값을 받을지..
        
//        WCSession.deac
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
        print("session \(session) activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
        
        if let error = error {
            print("\(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let logincheckInfo = applicationContext["logincheck"] as? String {
            print("applicationContext logincheck : \(logincheckInfo)")
            loginCheck = "\(logincheckInfo)"
        }
        
    }
    
    
    // 백그라운드 처리 전환 작업 소스 시작 지점
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let logincheckInfo = userInfo["logincheck"] as? String {
                print("transferCurrentComplicationUserInfo logincheck : \(logincheckInfo)")
                loginCheck = "\(logincheckInfo)"
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
        
        if let logincheckInfo = message["logincheck"] as? String {
                print(" data check : \(logincheckInfo)")
                loginCheck = logincheckInfo
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
        
        let startWorkoutSendData = ["StartWorkoutCall":"true","MyStageLvl": MyStageLvl]
        
        let action1 = WKAlertAction(title: "확인", style: .default) {}
        
        let healthDataAuthValue = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .heartRate)!).rawValue
        
        if healthDataAuthValue == 0 || healthDataAuthValue == 1{
            presentAlert(withTitle: "HealthKit 데이터 승인 필요", message: "팔피토 앱 HealthKit 데이터 사용 승인 해주세요.", preferredStyle: .alert, actions: [action1])
            return
        }else {
            
        }
        
        if loginCheck != "Yes" {
            presentAlert(withTitle: "팔피토 앱 로그인 필요", message: "팔피토 앱 로그인 해주세요.", preferredStyle: .alert, actions: [action1])
            return
        }
        
        
//        if(wcSession?.isReachable == true){
            
           tryWatchSendMessage(message: startWorkoutSendData as [String : Any])
//        }
        
        
        // 아이폰 통신 구간.. waek self memory leak 구간
        pushController(withName: "MainInterfaceController", context: context)
        
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
        
            // 해당 구간이 에러 일 확률이 크다 추후에 수정해야할 것이다.
//            if let validSession = self.wcSession {
//                //let data: [String: Any] = ["logincheck": "No" as Any]
//                //UserDefaults.standard.set("No" , forKey: "logincheck")
//                validSession.transferUserInfo(message)
//
//            }
        
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
             }else {
                self.wcSession?.transferUserInfo(message)
             }
           
    }
    
}
