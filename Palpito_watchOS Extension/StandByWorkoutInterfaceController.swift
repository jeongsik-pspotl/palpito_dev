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
    weak var wcfileSession:WCSessionFile?
    
    var myStageLevelData: String = "SL1"
    
    
    var launchWatchAppVal:String?
    
    let healthStore = HKHealthStore()
    //let fileManager = FileManager.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("1")
        // 여기서 강도 설정 값을 받을지..
        
        // event | error log 수집 기능 구현
        // directory 생성 단계
        /*
        let documentURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directoryURL = documentURL.appendingPathComponent("PALPITODIR")
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("ERROR")
            }
            
            // 1. 파일 쓰는 기능 추가
            let fileURL = directoryURL.appendingPathComponent("palpito_user.txt")
            
            let text = NSString(string: "green")
            
            try? text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            
            // 2. 파일 읽기 기능 추가
            do {
                // 파일 이름을 기존의 경로에 추가
                let helloPath = fileURL.appendingPathComponent("palpito_user.txt")

                // 내용 읽기
                let text2 = try String(contentsOf: helloPath, encoding: .utf8)

                print(text2)
            }
            catch let error as NSError {
                print("Error Reading File : \(error.localizedDescription)")
            }
            
        }
         */
        /*
        기본 기능 구현 하는데 필요한 소스 코드 찾았음
         해당 기능들 조합해서
         읽고 쓰고 다시 붙이는 기능을 구현해야함.
         
         이번주에 가능할때 붙이는 작업을 진행하고
         만들면서 디버깅도 하고
         애플워치에서 작업이 다되고
         파일 전송하고
         저장하고
         파일 다시 읽고
         파싱한 다음
         파이어베이스로 전송하고
         이 기능이 완료하고 나서
         
         */
        // 3. 여러번 반복 그외 기능 ...
        
        // 그외 기능 세부 적으로 검토하거나 분석 설계 작업이 필요함..
        
//        WCSession.deac
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            //wcSession?.finalize()
            //print("session \(String(describing: wcSession?.activationState.rawValue))")
            //print("session activate")
            guard let session = self.wcSession else { return }
                for transfer in session.outstandingUserInfoTransfers {
                    transfer.cancel()
                    
                }
            
        } else {
            //print("session error")
        }
        
        //var transContext:[String:String]?
        //transContext = ["transfile":"test"]
        
        // 행동 수집 구간 조건을 처리 잘 처리하기
        //wcSession?.transferFile(saveURL, metadata: transContext) // 보내는 구간
        
        // 파일을 쓰면서 처리하는 구간은 28일에 하는 걸로 ㅎ
        
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
            guard let session = self.wcSession else { return }
                for transfer in session.outstandingUserInfoTransfers {
                    transfer.cancel()
                    
                }
            
        } else {
            //print("session error")
        }
        
        //let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let directoryURL = documentURL.appendingPathComponent("NewDirectory")
        //let fileURL = directoryURL.appendingPathComponent("test.txt")
        
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("StandByWorkoutInterfaceController session \(session) activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
        
        if let error = error {
            print("\(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let logincheckInfo = applicationContext["logincheck"] as? String {
            
            loginCheck = "\(logincheckInfo)"
        }
        
    }
    
    
    // 백그라운드 처리 전환 작업 소스 시작 지점
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.global().async {
            if let logincheckInfo = userInfo["logincheck"] as? String {
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
        DispatchQueue.global().async {
            if let logincheckInfo = message["logincheck"] as? String {
                print(" data check : \(logincheckInfo)")
                loginCheck = logincheckInfo
            }
        }

        

    }


    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // 운동 화면으로 이동
    func workoutSendMainInterface(MyStageLvl: String){
        
        // directory 생성 단계
        /*
        let documentURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directoryURL = documentURL.appendingPathComponent("PALPITODIR")
        */
        
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
        /*
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("ERROR")
            }
            
            // 1. 파일 쓰는 기능 추가
            let fileURL = directoryURL.appendingPathComponent("palpito_user.txt")
            
            // 2. 파일 읽기 기능 추가
            do {
                // 파일 이름을 기존의 경로에 추가
                let helloPath = fileURL.appendingPathComponent("palpito_user.txt")

                // 내용 읽기
                let text2 = try String(contentsOf: helloPath, encoding: .utf8)

                print(text2)
                
                let text = NSString(string: text2 + "workout start")
                
                try? text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            }
            catch let error as NSError {
                print("Error Reading File : \(error.localizedDescription)")
            }
            
        }
         */
        
        
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
        // file write 처리 구간
        
        workoutSendMainInterface(MyStageLvl: "SL1")
        
    }
    
    
    @IBAction func relaxStartAction() {
        //print("MainRelaxInterfaceController action ?? ")
        
//        var context:[String:String]?
//        context = ["MyStageLvl": myStageLevelData]
        
        var startRelaxSendData:[String:String]?
        startRelaxSendData = ["StartRelaxCall":"true"]
        
        tryWatchSendMessage(message: startRelaxSendData! as [String : Any])
        
        // 응답 구간을 제대로 구현하고
        // 
        
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
        if WCSession.isSupported() {
             if self.wcSession != nil && self.wcSession?.activationState == .activated {
                    if self.wcSession?.isReachable == true {
                        //replyHandler in 응답이 정상인 구간일 경우 다음 화면으로 넘어가는 기능을 구현해야함.
                        self.wcSession?.sendMessage(message, replyHandler: { (reply: [String : Any]) -> Void in
                            //guard let result = reply["result"] else { return }
                            //print("test reply result")
                            //print(result)
                            guard let session = self.wcSession else { return }
                                for transfer in session.outstandingUserInfoTransfers {
                                    transfer.cancel()
                                    
                                }
                            
                        }) { (error) -> Void in
                            // If the message failed to send, queue it up for future transfer
                            
                            print(" StandByWorkoutInterfaceController error : \(error)")
                            self.wcSession?.transferUserInfo(message)
                            
                        }
                    }
             } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                 guard let session = self.wcSession else { return }
                     for transfer in session.outstandingUserInfoTransfers {
                         transfer.cancel()
                         
                     }
                 
                 self.wcSession?.transferUserInfo(message)
             }else {
                //self.wcSession?.transferUserInfo(message)
             }
        }
           
    }
    
}
