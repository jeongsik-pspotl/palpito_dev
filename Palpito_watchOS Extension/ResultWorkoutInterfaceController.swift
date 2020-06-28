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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("")
        
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
        
        backToMainTabSendData?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.popToRootController()
        }
        //wcSession = nil
        //print("resultWorkoutAction end")
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
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
