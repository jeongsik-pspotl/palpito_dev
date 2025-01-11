//
//  ResultRelaxInterfaceController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 23/05/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ResultRelaxInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    @IBOutlet weak var resultRelaxTime: WKInterfaceLabel!
    @IBOutlet weak var resultRelaxHeartRate: WKInterfaceLabel!
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    
    weak var wcSession = WCSession.default
    
    var resultRelaxEndTimeVal:String?
    var resultRelaxHeartRateVal:String?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            wcSession?.delegate = self
            wcSession?.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
        
        if let dict: [String:String] = context as? [String:String] {
            
            resultRelaxEndTimeVal    = dict["resultRelaxEndTime"]
            
        }
        
        self.resultRelaxHeartRateVal = self.healthKitShared?.mainAvgHeartRate
        
        let resultMsg = ["resultRelaxEndTimeVal":resultRelaxEndTimeVal, "resultRelaxHeartRateVal": self.resultRelaxHeartRateVal]
        
        wcSession?.transferUserInfo(resultMsg as [String : Any])
        
        wcSession?.sendMessage(resultMsg as [String : Any], replyHandler: nil, errorHandler: nil)
        
        self.resultRelaxTime.setText(self.resultRelaxEndTimeVal)
        self.resultRelaxHeartRate.setText(self.resultRelaxHeartRateVal)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    @IBAction func returnMainInterfaceAction() {
        //print("resultRelaxAction start")
        
        var backToMainTabSendData:[String:String]?
        backToMainTabSendData = ["backToMainTab":"true"]
        
        wcSession?.sendMessage(backToMainTabSendData!, replyHandler: nil, errorHandler: nil)
        wcSession?.transferUserInfo(backToMainTabSendData!)
        
        backToMainTabSendData?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.popToRootController()
        }
        //print("resultRelaxAction end")
        
    }
    

}
