//
//  RelaxInterfaceController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 22/05/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class RelaxInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var pauseOrPlaybtn: WKInterfaceButton!
    @IBOutlet weak var stopBtn: WKInterfaceButton!
    @IBOutlet weak var relaxTime: WKInterfaceLabel!
    @IBOutlet weak var relaxPalpi: WKInterfaceImage!
    @IBOutlet weak var palpiLoader: WKInterfaceImage!
    @IBOutlet weak var relaxPalpiText: WKInterfaceLabel!
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    
    var heartRateSamples: [HKQuantitySample] = [HKQuantitySample]()
    var workoutSession: HKWorkoutSession?
    var heartRateQuery: HKQuery?
    
    weak var wcSession:WCSession?
    
    var workoutStartDate: Date?
    var workoutPauseDate: Date?
    
    var mainQueue = DispatchQueue.global()
    let dispatchGroup = DispatchGroup()
    var workItem:DispatchWorkItem?
    var workoutMainTimer: DispatchSource?
    
    var palpiRelaxAnimation: [UIImage] = []
    
    var heartRateDataInt: Double?
    
    var startTimer = Timer()
    var secsTime = 0
    var isPlayAndPauseChecked = true
    var isWorkoutInProgress = false
    
    var resultAvgHeartRate = ""
    var resultEndTime = ""
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.palpiLoader.setHidden(true)
        self.palpiLoader.setWidth(70)
        self.palpiLoader.setHeight(70)
        self.palpiLoader.stopAnimating()
        
        self.relaxPalpi.startAnimating()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
        
        startTimerfunc()
        wcSession!.transferUserInfo(["startRelax":secsTime as Any])
        
        healthKitShared?.authorizeHealthKit { [weak self] (success, error) in
            
//            self?.healthKitShared?.readMostRecentSample()
            self?.startOrStopworkfunc(startOrEndCheck: true) // 수행 안하고 잘 돌아가는지 확인하기
        }
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func startOrStopworkfunc(startOrEndCheck:Bool) {
        //print("start ? end : \(startOrEndCheck)")
        
        if startOrEndCheck {
            
            //print("Start workout")
            startWorkoutSession()
            
        } else {
            
            //print("End workout")
            //            endWorkoutSession()
            
        }
        
        isWorkoutInProgress = !isWorkoutInProgress
        
    }
    
    @IBAction func resumeAndPlayAction() {
        isPlayAndPauseChecked = !isPlayAndPauseChecked
        
        if isPlayAndPauseChecked {
            // 이미지 변경
            self.pauseOrPlaybtn.setBackgroundImageNamed("pause")
            //            if let workoutTimer = workoutMainTimer {
            //                workoutTimer.resume()
            //            }
            //            mainQueue.resume()
            startWorkoutSession()
            self.workoutSession?.resume()
            startTimerfunc()
            let msgData = ["resumeRelaxTimer":"resume"]
            wcSession!.sendMessage(msgData, replyHandler: nil, errorHandler: nil) // 프론트 엔드 통신
            wcSession!.transferUserInfo(msgData) // 백엔드 통신
            //print("다시 시작!")
            
        } else {
            // 이미지 변경
            self.pauseOrPlaybtn.setBackgroundImageNamed("start")
            self.workoutPauseDate = Date()
            
            self.workoutSession?.pause()
            self.startTimer.invalidate()
            //print("중지!")
            // send message, transUserInfo 전송
            let msgData = ["stopRelaxTimer":"stop"]
            wcSession!.transferUserInfo(msgData) // 백엔드 통신
            //            mainQueue.suspend()
        }
    }
    
    @IBAction func resultRealxAction() {
        resultWorkoutInterfaceAction()
        
    }
    
    func startWorkoutSession() {
        
        if self.workoutSession == nil {
            createWorkoutSession()
        }
        
        guard let session = workoutSession else {
            //print("Cannot start a workout without a workout session")
            return
        }
        
        session.startActivity(with: Date())
        self.workoutStartDate = Date()
        
        //        startTimerfunc()
    }
    
    func createWorkoutSession() {
        
        let workoutConfiguration = HKWorkoutConfiguration()
        let workoutHealthStore = HKHealthStore()
        
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: workoutHealthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
        } catch {
            //print("Exception thrown")
        }
        
    }
    
    func endWorkoutSession(_ endDate: Date) {
        guard let session = workoutSession else {
            //print("Cannot start a workout without a workout session")
            return
        }
        //        session.stopActivity(with: Date()) getAVGHeartRate
        //print("endWorkoutSession start")
        session.pause()
        session.end()
        //        saveWorkout(endDate)
        startTimer.invalidate()
        //print("endWorkoutSession end")
        
    }
    
    func startTimerfunc(){
        startTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        relaxTime.setText("\(timeFormatted(secsTime))")
        secsTime += 1
        
        let palpiTextTimeStatusOn = self.secsTime % 8
        let palpiTextTimeStatusOff = self.secsTime % 18
        
        if palpiTextTimeStatusOn == 0 {
            
            self.relaxPalpiText.setText("그리고 내쉬세요.")
            
        }
            
        if palpiTextTimeStatusOff == 0 {
            
            self.relaxPalpiText.setText("숨을 들이쉬세요.")
        }
        
        
    }
    
    func timeFormatted(_ totalSeconds:Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hour:Int = totalSeconds / 3600
        
        return String(format: "%02d:%02d:%02d", hour, minutes, seconds)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    // call resultWorkoutInterfaceController
    func resultWorkoutInterfaceAction (){
        
        self.relaxPalpi.stopAnimating()
        self.palpiLoader.setHidden(false)
        self.palpiLoader.startAnimating()
        //        //print("End workout")
        //        //print("End workout contextForSegue")
        //        //print("resultEndTime    : \(self.resultEndTime)")
        //        //print("resultCalSum     : \(self.resultCalSum)")
        //        //print("resultscoreTimer : \(self.resultscoreTimer)")
        var context:[String:String]?
        
        // test getAVGHeartRate
        let msgData = ["stopRelaxTimer":"stop"]
        wcSession!.transferUserInfo(msgData) // 백엔드 통신
        
        self.resultAvgHeartRate = (self.healthKitShared?.getAVGHeartRate(workoutStartDate!))!
        
        context = ["resultRelaxEndTime": "\(self.resultEndTime)"]

        //print("resultRelaxEndTime data check :  \(self.resultEndTime)")
        //  self.workItem?.cancel()
        mainQueue.suspend()
        self.endWorkoutSession(Date())
        
        //print("self.healthKitShared.mainAvgHeartRate : \(String(describing: self.healthKitShared?.mainAvgHeartRate))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.pushController(withName: "ResultRelaxInterfaceController", context: context)
            self.palpiLoader.stopAnimating()
            self.palpiLoader.setHidden(true)
            
//            context?.removeAll()
        }
    
    }

}

extension RelaxInterfaceController: HKWorkoutSessionDelegate {
    
    public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //print("Workout failed with error: \(error)")
        
    }
    
    public func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        switch toState {
        case .running:
            //print("workout started")
            
            guard let workoutStartDate = workoutStartDate else {
                return
            }
            
            // weak self [] 첨부
            if let query = healthKitShared?.createHeartRateStreamingQuery(workoutStartDate) {
                self.heartRateQuery = query
                self.healthKitShared?.heartRateDelegate = self
                healthKitShared?.healthStore.execute(query)
                
            }
            
            
        case .paused:
            
            //print("work out pause start!!! ")
            
            if let query = self.heartRateQuery {
                healthKitShared?.healthStore.stop(query)
                
            }
            
        case .stopped:
            //print("workout stopped")
            if let query = self.heartRateQuery {
                healthKitShared?.healthStore.stop(query)
                
            }
            
            
        case .ended:
            //print("workout ended")
            if let query = self.heartRateQuery {
                healthKitShared?.healthStore.stop(query)
                
            }
            
        default: break
            //print("Other workout state")
        }
        
    }
    
}

extension RelaxInterfaceController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
        mainQueue.async {
            
            guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
                return
            }
            
            self.heartRateSamples = heartRateSamples
            guard let sample = heartRateSamples.first else {
                return
            }
            
            let heartDataValue = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            // ({ (나이 * 0.2017) + (몸무게 * 0.1988) + (heartDataValue * 0.6309) - 55.0969 }* 0.016667) / 4.184
            //print(" heartRate value data check... :  \(heartDataValue)")
            self.heartRateDataInt = heartDataValue
            
            let heartRateString = String(format: "%.00f", heartDataValue)
            
            let relaxStatus = "on"
            
            //  심박수, 시간 전송 RelaxStringValueZoneStatus
            let msg = ["RelaxStringValueHeartRate" : "\(heartRateString)", "RelaxStringValueTimer": "\(self.timeFormatted(self.secsTime))", "RelaxStringValueZoneStatus": "\(relaxStatus)"]
            
            // transferUserInfo test...
            self.wcSession!.transferUserInfo(msg)
            
            self.wcSession!.sendMessage(msg, replyHandler: nil, errorHandler: nil)
            
//            self.heartRateLabel.setText(heartRateString)
            
            self.resultEndTime = "\(self.timeFormatted(self.secsTime))"
        }
        
        
    }
    
    
}
