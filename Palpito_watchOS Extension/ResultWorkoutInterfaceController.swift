//
//  WorkoutInterfaceController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 11/01/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ResultWorkoutInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var resultEndTimer: WKInterfaceLabel!
    
    @IBOutlet weak var resultHeartRateText: WKInterfaceLabel!
    
    @IBOutlet weak var resultCalText: WKInterfaceLabel!
    
    @IBOutlet weak var resultScoreCountText: WKInterfaceLabel!
    
    @IBOutlet weak var resultMeterText: WKInterfaceLabel!
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    
    weak var wcSession:WCSession?
    
    var resultEndTimeVal:String?
    var resultHeartRateVal:String?
    var resultCalVal:String?
    var resultScoreCountVal:String?
    var resultMetersVal:String?
    
    //let fileManager = FileManager.default

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("")
        
//        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let directoryURL = documentURL.appendingPathComponent("NewDirectory")
//        let fileURL = directoryURL.appendingPathComponent("test.txt")
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
        
        if let dict: [String:String] = context as? [String:String] {
            
            resultEndTimeVal    = dict["resultEndTime"]
            resultCalVal        = dict["resultCalSum"]
            resultScoreCountVal = dict["resultscoreTimer"]
            resultMetersVal     = dict["resultTotalAvgMeter"]
        }
        
        self.resultHeartRateVal = self.healthKitShared?.mainAvgHeartRate
        
        // 총 운동 시간, 총 칼로리, 총 점수 산정 콘솔 로그 체킹
        //print("resultEndTimeVal     : \(String(describing: self.resultEndTimeVal))")
        //print("resultCalVal         : \(String(describing: self.resultCalVal))")
        //print("resultScoreCountVal  : \(String(describing: self.resultScoreCountVal))")
        //print("resultHeartRateVal   : \(String(describing: self.resultHeartRateVal))")
        //print("resultMetersVal      : \(String(describing: self.resultMetersVal))")
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
            
            let text = NSString(string: "result")
            
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
            
        }else {
            // 기존 파일 경로가 존재하면
            // 기존에 파일을 쓰고 처리하는 기능을 새로 구현해야함.
            // 여러가지 조건, 분기처리 경우의 수를 경험으로 감지하며
            // 구현해야함.
            
            
        }
         */
        
        let resultMsg = ["resultEndTimeVal":resultEndTimeVal, "resultCalVal":resultCalVal, "resultScoreCountVal":resultScoreCountVal, "resultHeartRateVal": self.resultHeartRateVal, "resultMetersVal": self.resultMetersVal]
        
        self.tryWatchSendMessage(message: resultMsg as [String : Any])
        
        self.resultEndTimer.setText(self.resultEndTimeVal)
        self.resultCalText.setText(self.resultCalVal)
        self.resultScoreCountText.setText(self.resultScoreCountVal!)
        self.resultHeartRateText.setText(self.resultHeartRateVal)
        self.resultMeterText.setText(self.resultMetersVal!)
        
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
//    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
//        //print("segueIdentifier : \(segueIdentifier)")
////        MainWorkOut.endWorkoutSession()
//        return self
//    }
    
    @IBAction func resultWorkoutAction() {
        //print("resultWorkoutAction start")

        var backToMainTabSendData:[String:String]?
        backToMainTabSendData = ["backToMainTab":"true"]
        
        self.tryWatchSendMessage(message: backToMainTabSendData! as [String : Any])
        
        // backToMainTabSendData?.removeAll()
        
        // 파일 내용 전달하는 기능 구현
        // 상상 코딩하기
        // 행동 수집 구간 조건을 처리 잘 처리하기
        /*
        let documentURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directoryURL = documentURL.appendingPathComponent("PALPITODIR")
        
        // 보낼시에 처리하는 과정은 추후에 고민하면서 구현하기 
        if fileManager.fileExists(atPath: directoryURL.path) {
            let fileURL = directoryURL.appendingPathComponent("palpito_user.txt")
            
            var transContext:[String:String]?
            transContext = ["transfile":"test"]
            
            wcSession?.transferFile(fileURL, metadata: transContext) // 보내는 구간
        }
        
        */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.popToRootController()
        }
        //wcSession = nil
        //print("resultWorkoutAction end")
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func tryWatchSendMessage(message: [String : Any]) {
        // 해당 구간이 에러 일 확률이 크다 추후에 수정해야할 것이다.
        if WCSession.isSupported() {
            if self.wcSession != nil && self.wcSession?.activationState == .activated {
                if self.wcSession?.isReachable == true {
                    self.wcSession?.sendMessage(message, replyHandler: { (reply: [String : Any]) -> Void in
                        guard let result = reply["result"] else { return }
                        // print("ResultWorkoutInterfaceController reply result")
                        // print(result)
                        
                    }) { (error) -> Void in
                        // If the message failed to send, queue it up for future transfer
                        print(" ResultWorkoutInterfaceController error : \(error)")
                        if error == nil {
                            //print(" ResultWorkoutInterfaceController error : \(error)")
                            self.wcSession?.transferUserInfo(message)
                        }else {
                            print(" ResultWorkoutInterfaceController error : \(error)")
                        }
                        
                    }
                }
            } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                self.wcSession?.transferUserInfo(message)
            } else {
                self.wcSession?.transferUserInfo(message)
            }
            
        }else {
            
        }
              
    }
}
