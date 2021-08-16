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
    
    let fileManager = FileManager.default

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("")
        
//        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let directoryURL = documentURL.appendingPathComponent("NewDirectory")
//        let fileURL = directoryURL.appendingPathComponent("test.txt")
        let text = NSString(string: "result workout interfase controller start ")
        
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
        
        let resultMsg = ["resultEndTimeVal":resultEndTimeVal, "resultCalVal":resultCalVal, "resultScoreCountVal":resultScoreCountVal, "resultHeartRateVal": self.resultHeartRateVal, "resultMetersVal": self.resultMetersVal]
        
        self.tryWatchSendMessage(message: resultMsg as [String : Any])
        //wcSession?.transferUserInfo(resultMsg as [String : Any])
        //wcSession?.sendMessage(resultMsg as [String : Any], replyHandler: nil, errorHandler: nil)
        
        self.resultEndTimer.setText(self.resultEndTimeVal)
        self.resultCalText.setText(self.resultCalVal)
        self.resultScoreCountText.setText(self.resultScoreCountVal!)
        self.resultHeartRateText.setText(self.resultHeartRateVal)
        self.resultMeterText.setText(self.resultMetersVal!)
        
                
        do {
            if let fileUpdater = try? FileHandle(forUpdating: saveURL) {

                    // Function which when called will cause all updates to start from end of the file
                fileUpdater.seekToEndOfFile()

                    // Which lets the caller move editing to any position within the file by supplying an offset
                fileUpdater.write(text.data(using: .zero, allowLossyConversion: false)!)

                    // Once we convert our new content to data and write it, we close the file and that’s it!
                fileUpdater.closeFile()
            }
            
            // 여기서 강도 설정 값을 받을지..
            var transContext:[String:String]?
            transContext = ["transfile":"test"]
            
            // 행동 수집 구간 조건을 처리 잘 처리하기
             wcSession?.transferFile(saveURL, metadata: transContext) // 보내는 구간
            
        } catch let e {
            print(e.localizedDescription)
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
        //wcSession?.sendMessage(backToMainTabSendData!, replyHandler: nil, errorHandler: nil)
        //wcSession?.transferUserInfo(backToMainTabSendData!)
        
        // backToMainTabSendData?.removeAll()
        
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
//        if let validSession = self.wcSession {
//            //let data: [String: Any] = ["logincheck": "No" as Any]
//            //UserDefaults.standard.set("No" , forKey: "logincheck")
//            validSession.transferUserInfo(message)
//
//        }
           
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
        } else {
            self.wcSession?.transferUserInfo(message)
        }
              
    }
}
