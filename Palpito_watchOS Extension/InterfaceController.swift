//
//  InterfaceController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 31/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


public class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var caloriWorkoutData: WKInterfaceLabel!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var scoreTimeText: WKInterfaceLabel!
    @IBOutlet weak var zoneStatusImage: WKInterfaceImage!
    @IBOutlet weak var endWorkoutBtn: WKInterfaceButton!
    @IBOutlet weak var palpiLoader: WKInterfaceImage!
    @IBOutlet weak var pauseAndPlayButton: WKInterfaceButton!
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    weak var wcSession:WCSession?
    var isWorkoutInProgress = false
    var workoutSession: HKWorkoutSession?
    var workoutStartDate: Date?
    var workoutPauseDate: Date?
    var heartRateQuery: HKQuery?
    var metersDataQuery: HKQuery?
    var activeEnergyBurnedDataQuery: HKQuery?
    
    var heartRateSamples: [HKQuantitySample] = [HKQuantitySample]()
    var metersDataSamples: [HKQuantitySample] = [HKQuantitySample]()
    var activiyEnergyBurnDataSamples: [HKQuantitySample] = [HKQuantitySample]()
    
    var workoutMainTimer: DispatchSource?
    var activityEnergyBurnItem: DispatchWorkItem?
    
    var heartRateDataInt: Double?
    var totalSum: Double = 0.0
    var totalMeterSum: Double = 0.0
    var secsMeterDbl: Double = 0.0
    var secsEnergyBurnDbl: Double = 0.0
    var secsTime = 0
    var startTimer = Timer()
    
    var scoreTime:Int?
//    var scoreZone1Cnt:Int = 0
//    var scoreZone2Cnt:Int = 0
//    var scoreZone3Cnt:Int = 0
//    var scoreZone4Cnt:Int = 0
//    var scoreZone5Cnt:Int = 0
    var scoreResultZone:Int = 0
//    var zoneStatus1LowTension:Int = 0
//    var zoneStatus2LowTension:Int = 0
//    var zoneStatusGoodjob:Int = 0
//    var zoneStatus4HighTension:Int = 0
//    var zoneStatus5HighTension:Int = 0
    
    var startStageLevelData:String = ""
    
    var userHeartRateZ1:Double?
    var userHeartRateZ2:Double?
    var userHeartRateZ3:Double?
    var userHeartRateZ4:Double?
    var userHeartRateZ5:Double?
    var userDefaultHeartRate:Double?
    var zoneStatus = ""
    var tensionZoneStatus = ""
    
    var resultscoreTimer = ""
    var resultEndTime = ""
    var resultCalSum = ""
    var resultAvgHeartRate = ""
    var resultAvgMeters = ""
    var isPlayAndPauseChecked = true
    
    //let fileManager = FileManager.default
    

    override public func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("")
        //  self.workoutButton.setEnabled(false)
        self.palpiLoader.setHidden(true)
        self.palpiLoader.setWidth(70)
        self.palpiLoader.setHeight(70)
        self.palpiLoader.stopAnimating()
        
        if let dict: [String:String] = context as? [String:String] {
            startStageLevelData = dict["MyStageLvl"]!
            
        }
        // //print("awake check : \(startStageLevelData)")
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            
            //print("session activate")
            
        } else {
            //print("session error")
            
        }
        
        // healthRate user data setting
        setMyStageLevelZone(myStageLevelData: startStageLevelData)
        
        startTimerfunc()
        // change wcsession
         // self.tryWatchSendMessage(message: ["startWorkout":scoreTime as Any])
        //wcSession!.transferUserInfo(["startWorkout":scoreTime as Any])
        healthKitShared?.authorizeHealthKit { [weak self] (success, error) in
            
            self?.healthKitShared?.readMostRecentSample()
            self?.startOrStopworkfunc(startOrEndCheck: true)
        }
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
            
            let text = NSString(string: "start")
            
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
        
    }
    
    override init() {
        // healthRate user data setting

    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    override public func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let directoryURL = documentURL.appendingPathComponent("NewDirectory")
        //let fileURL = directoryURL.appendingPathComponent("test.txt")
    
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
            //print("session activate")
        } else {
            //print("session error")
        }
            
            //try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
            
            //try text.write(to: saveURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            
            //let text10 = try String(contentsOf: saveURL, encoding: .utf8)
            //print(text10)
        
        
        
    }
    
    override public func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.scoreTime = 0
        super.didDeactivate()
    }
    
    @IBAction func endWorkoutAction() {
        // text write
        
        resultWorkoutInterfaceAction()
        
    }
    
    @IBAction func pauseAndReseumAction(){
        isPlayAndPauseChecked = !isPlayAndPauseChecked
        
        if isPlayAndPauseChecked {
            // 이미지 변경
            self.pauseAndPlayButton.setBackgroundImageNamed("pause")
            
//            if let workoutTimer = workoutMainTimer {
//                workoutTimer.resume()
//            }
//            mainQueue.resume()
            startWorkoutSession()
            self.workoutSession?.resume()
            startTimerfunc()
            let msgData = ["resumeTimer":"resume"]
            // change wcsession
            self.tryWatchSendMessage(message: msgData as [String : Any])
            //wcSession!.sendMessage(msgData, replyHandler: nil, errorHandler: nil) // 프론트 엔드 통신
            //wcSession!.transferUserInfo(msgData) // 백엔드 통신
            //print("다시 시작!")
        } else {
            // 이미지 변경
            self.pauseAndPlayButton.setBackgroundImageNamed("start")
            self.workoutPauseDate = Date()
            
            self.workoutSession?.pause()
            self.startTimer.invalidate()
            //print("중지!")
            // send message, transUserInfo 전송
            let msgData = ["stopTimer":"stop"]
            // change wcsession
            self.tryWatchSendMessage(message: msgData as [String : Any])
            // wcSession!.transferUserInfo(msgData) // 백엔드 통신
            // mainQueue.suspend()
        }
    }
    
    // 해당 액션은 중지
    @IBAction func startOrStopworkAction() {
        
        if isWorkoutInProgress {
            //print("End workout")
            //  endWorkoutSession()
        } else {
            
            //print("Start workout")
            startWorkoutSession()
            
        }
        
        isWorkoutInProgress = !isWorkoutInProgress
        // self.workoutButton.setTitle(isWorkoutInProgress ? "End Workout" : "Start Workout")
        
    }

    
    func startOrStopworkfunc(startOrEndCheck:Bool) {
        //print("start ? end : \(startOrEndCheck)")
        
        if startOrEndCheck {
            
            //print("Start workout")
            startWorkoutSession()
            
        } else {
            
            //print("End workout")
            // endWorkoutSession()
            
        }
        
        isWorkoutInProgress = !isWorkoutInProgress
    }
    
    func createWorkoutSession() {
        
        let workoutConfiguration = HKWorkoutConfiguration()
        let workoutHealthStore = HKHealthStore()
        
        workoutConfiguration.activityType = .running
        workoutConfiguration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: workoutHealthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
        } catch {
            //print("Exception thrown")
        }
        
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
        
        // startTimerfunc()
    }
    
    func endWorkoutSession(_ endDate: Date) {
        guard let session = workoutSession else {
            //print("Cannot start a workout without a workout session")
            return
        }
        // session.stopActivity(with: Date()) getAVGHeartRate
        //print("endWorkoutSession start")
        session.pause()
        session.end()
        // saveWorkout(endDate)
        startTimer.invalidate()
        //print("endWorkoutSession end")
        
    }
    
    func saveWorkout(_ endDate: Date) {
        
        guard let startDate = workoutStartDate else {
            return
        }
        
        let workout = HKWorkout(activityType: .running, start: startDate, end: endDate)
        
        healthKitShared?.healthStore.save(workout) { [weak self] (success, error) in
            //print("Was save workout successful? \(success)")
            
            guard let samples = self?.heartRateSamples else {
                return
            }
            
            self?.healthKitShared?.healthStore.add(samples, to: workout, completion: { (success, error) in
                if success {
                    //print("Successfully saved heart rate samples.")
                }
            })
        }
    }
    
    func startTimerfunc(){
        startTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        timerLabel.setText("\(timeFormatted(secsTime))")
        secsTime += 1
        
//        var zoneStatusTensionVoice:[String:String]?
        
        // 2분이 지나고 심박구간 카운트 하여 점수 산정 알고리즘
        let scoreTimeStatus = self.scoreTime! % 120
        if scoreTimeStatus == 0 {
            self.scoreResultTimer()
            self.tension2MinTimer()
        }
        
        // 해당 구간에서 3분동안 구간에 도달 했을시 음성 피드백 실행하기
        let tensionTimeZoneStatus = self.scoreTime! % 180
        if tensionTimeZoneStatus == 0 {
            // self.tensionTimer()// as is 소스
            self.tensionStatus3MinTimer()
        }
        
        // 해당 구간에서 3분동안 구간에 도달 했을시 음성 피드백 실행하기
        
        //print(" scoreResultZone : \(self.scoreResultZone) ")
    }
    
    func timeFormatted(_ totalSeconds:Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hour:Int = totalSeconds / 3600
        
        // 점수 산정을 위해 scoreTime 변수 저장
        // 현재 시간 - 중지 시간 - 시작 시간 = 합친 시간
        scoreTime = secsTime
//        //print("scoreTime : \(String(describing: scoreTime))")
        return String(format: "%02d:%02d:%02d", hour, minutes, seconds)
    }
    
    func setMyStageLevelZone(myStageLevelData:String) {
        // healthRate user data setting
        let (age, _) = (self.healthKitShared?.readProfile())!
//        //print("start check init !!")
//        //print("check init data : \(myStageLevelData) !!").
        
        if myStageLevelData == "SL1"{
            userDefaultHeartRate = ((Double(exactly: self.healthKitShared!.bpmRatefun)! - Double(exactly: age!)!) * 0.8)
            userHeartRateZ1 = (userDefaultHeartRate! * 0.5)
            userHeartRateZ2 = (userDefaultHeartRate! * 0.6)
            userHeartRateZ3 = (userDefaultHeartRate! * 0.7)
            userHeartRateZ4 = (userDefaultHeartRate! * 0.8)
            userHeartRateZ5 = (userDefaultHeartRate! * 0.9)
//            //print("Stage Level : \(myStageLevelData)")
//            //print("age : \(String(describing: age))")
//            //print("zone 1 :  \(String(describing: userHeartRateZ1))")
//            //print("zone 2 : \(String(describing: userHeartRateZ2))")
//            //print("zone 3 : \(String(describing: userHeartRateZ3))")
//            //print("zone 4 : \(String(describing: userHeartRateZ4))")
//            //print("zone 5 : \(String(describing: userHeartRateZ5))")
            
        } else if myStageLevelData == "SL2"{
            userDefaultHeartRate = ((Double(exactly: self.healthKitShared!.bpmRatefun)! - Double(exactly: age!)!) * 1.0)
            userHeartRateZ1 = (userDefaultHeartRate! * 0.5)
            userHeartRateZ2 = (userDefaultHeartRate! * 0.6)
            userHeartRateZ3 = (userDefaultHeartRate! * 0.7)
            userHeartRateZ4 = (userDefaultHeartRate! * 0.8)
            userHeartRateZ5 = (userDefaultHeartRate! * 0.9)
//            //print("Stage Level : \(myStageLevelData)")
//            //print("age : \(String(describing: age))")
//            //print("zone 1 :  \(String(describing: userHeartRateZ1))")
//            //print("zone 2 : \(String(describing: userHeartRateZ2))")
//            //print("zone 3 : \(String(describing: userHeartRateZ3))")
//            //print("zone 4 : \(String(describing: userHeartRateZ4))")
//            //print("zone 5 : \(String(describing: userHeartRateZ5))")
            
        } else if myStageLevelData == "SL3"{
            userDefaultHeartRate = ((Double(exactly: self.healthKitShared!.bpmRatefun)! - Double(exactly: age!)!) * 1.1)
            userHeartRateZ1 = (userDefaultHeartRate! * 0.5)
            userHeartRateZ2 = (userDefaultHeartRate! * 0.6)
            userHeartRateZ3 = (userDefaultHeartRate! * 0.7)
            userHeartRateZ4 = (userDefaultHeartRate! * 0.8)
            userHeartRateZ5 = (userDefaultHeartRate! * 0.9)
//            //print("Stage Level : \(myStageLevelData)")
//            //print("age : \(String(describing: age))")
//            //print("zone 1 :  \(String(describing: userHeartRateZ1))")
//            //print("zone 2 : \(String(describing: userHeartRateZ2))")
//            //print("zone 3 : \(String(describing: userHeartRateZ3))")
//            //print("zone 4 : \(String(describing: userHeartRateZ4))")
//            //print("zone 5 : \(String(describing: userHeartRateZ5))")
        }
        
    }
    
    // 운동 피드백 산정 2분기준 as-is
    func tensionTimer(){
        
        var zoneStatusTensionVoice:[String:String]?
        
        // tensionZoneStatus == "zt1"
        if self.tensionZoneStatus == "zt1" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone1Voice"]
            // change wcssession
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }
                
         if self.tensionZoneStatus == "zt2" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone2Voice"]
            // change wcssession
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }

        if self.tensionZoneStatus == "zt3" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone3Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
            // 햅틱 기동
            WKInterfaceDevice.current().play(.notification)

        }
        
        if self.tensionZoneStatus == "zt4" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone4Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
            // 햅틱 기동
            WKInterfaceDevice.current().play(.notification)
                    
        }
        
        if self.tensionZoneStatus == "zt5" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone5Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }
    }
    
    // 운동 피드백 3분 산정 zone 3,4
    func tensionStatus3MinTimer(){
        var zoneStatusTensionVoice:[String:String]?

        if self.tensionZoneStatus == "zt3" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone3Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
            // 햅틱 기동
            WKInterfaceDevice.current().play(.notification)

        }
        
        if self.tensionZoneStatus == "zt4" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone4Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
            // 햅틱 기동
            WKInterfaceDevice.current().play(.notification)
                    
        }
        
    }
    
    // 운동 피드백 산정 2분기준 1,2,5
    func tension2MinTimer(){
        
        var zoneStatusTensionVoice:[String:String]?
        
        // tensionZoneStatus == "zt1"
        if self.tensionZoneStatus == "zt1" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone1Voice"]
            // change wcssession
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }
                
         if self.tensionZoneStatus == "zt2" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone2Voice"]
            // change wcssession
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }
        
        if self.tensionZoneStatus == "zt5" {
            zoneStatusTensionVoice = ["zoneStatusTensionVoice":"zone5Voice"]
            self.tryWatchSendMessage(message: zoneStatusTensionVoice!)
                    
        }
    }
    
    // 운동 점수 산정
    func scoreResultTimer(){
        
        if self.zoneStatus == "z1" {
            // zone 1 구간이 제일 많은 경우
            self.scoreResultZone += 1
            
        }else if self.zoneStatus == "z2" {
            // zone 2 구간이 제일 많은 경우
            self.scoreResultZone += 3
            
        }else if self.zoneStatus == "z3" {
            // zone 3 구간이 제일 많은 경우
            self.scoreResultZone += 10
            
        }else if self.zoneStatus == "z4" {
            // zone 4 구간이 제일 많은 경우
            self.scoreResultZone += 12
            
        }else if self.zoneStatus == "z5" {
            // zone 5 구간이 제일 많은 경우 | 추후에 수정이 필요함.
            self.scoreResultZone += 3
            
        }
        
        //print("to be score : \(self.scoreResultZone)")
        
    }
    
    // call resultWorkoutInterfaceController
    func resultWorkoutInterfaceAction (){
        DispatchQueue.global().sync { [weak self] in
        
            self!.palpiLoader.setHidden(false)
            self!.palpiLoader.startAnimating()
            self!.endWorkoutBtn.setEnabled(false)
            self!.pauseAndPlayButton.setEnabled(false)
    //        //print("End workout")
    //        //print("End workout contextForSegue")
    //        //print("resultEndTime    : \(self.resultEndTime)")
    //        //print("resultCalSum     : \(self.resultCalSum)")
    //        //print("resultscoreTimer : \(self.resultscoreTimer)")
            var context:[String:String]?
            var totalAvgMeter: Double?
            
            self!.resultCalSum = String(format: "%.01f", self!.totalSum)
            //test getAVGHeartRate
            //        //print("test get AVG hearRate")
            let msgData = ["stopTimer":"stop"]
            // chage wcsession
            DispatchQueue.global().async {
                self!.tryWatchSendMessage(message: msgData as [String : Any])
            }
            
            //wcSession!.transferUserInfo(msgData) // 백엔드 통신
            
            self!.resultAvgHeartRate = (self!.healthKitShared?.getAVGHeartRate(self!.workoutStartDate!))!
            //        self.resultAvgMeters = self.healthKitShared.getAVGWalkingRunning(workoutStartDate)
            totalAvgMeter = (self!.secsMeterDbl * 60 * 60) / 1000
            //print("resultTotalAvgMeter : \(String(describing: totalAvgMeter))")
            
            
            context = ["resultEndTime": "\(self!.resultEndTime)","resultCalSum": "\(self!.resultCalSum)", "resultscoreTimer": "\(self!.resultscoreTimer)", "resultTotalAvgMeter": String(format: "%.00f", totalAvgMeter!)]
            
            self!.scoreTime = 0
            self!.resultCalSum = ""
            self!.resultEndTime = ""
            self!.resultscoreTimer = ""
    //        self.workItem?.cancel()
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self!.endWorkoutSession(Date())
                    self!.pushController(withName: "ResultWorkoutInterfaceController", context: context)
                    self!.palpiLoader.stopAnimating()
                    self!.palpiLoader.setHidden(true)
                    
        //            context?.removeAll()
                }
            }
        }
        //print("self.healthKitShared.mainAvgHeartRate : \(String(describing: self.healthKitShared?.mainAvgHeartRate))")
        
        //        return context
        
        //        dismiss()
        //        endWorkoutSession()
    
    
}

extension InterfaceController: HKWorkoutSessionDelegate {
    
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
                
                if let meterQuery = healthKitShared?.createWalkingRunningStreamingQuery(workoutStartDate) {
                    self.metersDataQuery = meterQuery
                    self.healthKitShared?.meterDataDelegate = self
                    healthKitShared?.healthStore.execute(meterQuery)
                    
                }
                
                if let query = healthKitShared?.createHeartRateStreamingQuery(workoutStartDate) {
                    self.heartRateQuery = query
                    self.healthKitShared?.heartRateDelegate = self
                    healthKitShared?.healthStore.execute(query)
                    
                }
            
                if let activeEnergyBurnedQuery = healthKitShared?.createActiveEnergyBurnedStreamingQuery(workoutStartDate) {
                    self.activeEnergyBurnedDataQuery = activeEnergyBurnedQuery
                    self.healthKitShared?.activeEnergyBurnedDelegate = self
                    healthKitShared?.healthStore.execute(activeEnergyBurnedQuery)
                    
                }
            
            
            case .paused:
                
                //print("work out pause start!!! ")
            
                if let query = self.heartRateQuery {
                    healthKitShared?.healthStore.stop(query)
                    
                }
                
                if let meterQuery = self.metersDataQuery {
                    healthKitShared?.healthStore.stop(meterQuery)
                }
            
            case .stopped:
                //print("workout stopped")
                if let query = self.heartRateQuery {
                    healthKitShared?.healthStore.stop(query)
                    
                }
            
                if let meterQuery = self.metersDataQuery {
                    healthKitShared?.healthStore.stop(meterQuery)
                }
            
            case .ended:
                //print("workout ended")
                if let query = self.heartRateQuery {
                    healthKitShared?.healthStore.stop(query)

                }
            
                if let meterQuery = self.metersDataQuery {
                    healthKitShared?.healthStore.stop(meterQuery)
                }

        default: break
                //print("Other workout state")
        }
        
    }
    
    
}



//활동 칼로리 출력 
extension InterfaceController: ActiveEnergyBurnedDelegate {
    func activeEnergyBurnedDelegate(activeEnergyBurned: [HKSample]) {
        DispatchQueue.main.async { [weak self] in
            guard let activeEnergyBurned =  activeEnergyBurned as? [HKQuantitySample] else {
                return
            }
            
            self!.activiyEnergyBurnDataSamples = activeEnergyBurned
            guard let sample = activeEnergyBurned.first else {
                return
            }
            
            let activityEnergyBurnValue = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            
            //print(" activityEnergyBurn data check... :  \(activityEnergyBurnValue)")
            self!.totalSum = self!.totalSum + activityEnergyBurnValue
//            self.resultCalSum = String(format: "%.0f", self.totalSum)
            
            self!.caloriWorkoutData.setText(String(format: "%.01f", self!.totalSum))
            
            let msg = ["StringValueKcalData" : "\(String(format: "%.01f", self!.totalSum))"]
            // change
            self!.tryWatchSendMessage(message: msg as [String : Any])
        }
        
    }
        
}

extension InterfaceController: MeterDataDelegate {
    
    func meterDataUpdated(meterDataSamples: [HKSample]) {
        
        DispatchQueue.main.async { [weak self] in
            guard let meterDataSamples = meterDataSamples as? [HKQuantitySample] else {
                return
            }
            
            self!.metersDataSamples = meterDataSamples
            guard let sample = meterDataSamples.first else {
                return
            }
            
            let meterDataValue = sample.quantity.doubleValue(for: HKUnit.meter())
            
            //print(" meterData data check... :  \(meterDataValue)")
            self!.secsMeterDbl = meterDataValue
            
        }
        
//        dispatchGroup.notify(queue: mainQueue, work: self.meterItem!)
        
    }
}

extension InterfaceController: HeartRateDelegate {
    
    
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
//        let (age, _) = (self.healthKitShared?.readProfile())!
        
        // 수정 시작 구간.
//        guard let workoutTimer = DispatchSource.makeTimerSource() as? DispatchSource else {
//            return
//        }
        
        DispatchQueue.main.async { [weak self] in
            
            // directory 생성 단계
            /*
            let documentURL = self!.fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let directoryURL = documentURL.appendingPathComponent("PALPITODIR")
             */
            
            guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
                return
            }
             
            
            self!.heartRateSamples = heartRateSamples
            guard let sample = heartRateSamples.first else {
                return
            }
            
            let heartDataValue = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            // ({ (나이 * 0.2017) + (몸무게 * 0.1988) + (heartDataValue * 0.6309) - 55.0969 }* 0.016667) / 4.184
            //print(" heartRate value data check... :  \(heartDataValue)")
            self!.heartRateDataInt = heartDataValue
            //print("mainColWeightInt check... :  \(String(describing: self.healthKitShared?.mainColWeightInt)) ")
            
            // 남자 칼로리 공식
//            let ageAvg:Double = (Double(exactly: age!)! * 0.2107 )
//            let weightAvg:Double = (self.healthKitShared!.mainColWeightInt * 0.1988)
//            let heartRateAvg:Double = (heartDataValue * 0.6309)
//            //print("ageAvg")
//            //print(ageAvg)
//            //print("weightAvg")
//            //print(weightAvg)
//            //print("heartRateAvg")
//            //print(heartRateAvg)
            
//            let sum = ((ageAvg + weightAvg + heartRateAvg) - 55.0969) * 0.016667 / 4.184
            
//            self.totalSum = self.totalSum + sum
            
            let heartRateString = String(format: "%.00f", heartDataValue)
//            let kcalDataSum = String(format: "%.00f", self.totalSum)
            
            
            // 심박 구간 알고리즘
            switch heartDataValue {
            case 0..<self!.userHeartRateZ2!:
                self!.zoneStatus = "z1"
                self!.tensionZoneStatus = "zt1"
                self!.zoneStatusImage.setImageNamed("watchZone1")
//                self.scoreZone1Cnt += 1
                
//                self.zoneStatus1LowTension += 1
//                self.zoneStatus2LowTension += 1
//                self.zoneStatusGoodjob = 0
//                self.zoneStatus4HighTension = 0
//                self.zoneStatus5HighTension = 0
                
//                //print("zone 1 \(self.scoreZone1Cnt)")
//                //print("zone 1 LowTension \(self.zoneStatus1LowTension)")
                
            case self!.userHeartRateZ2!..<self!.userHeartRateZ3!:
                self!.zoneStatus = "z2"
                self!.tensionZoneStatus = "zt2"
                self!.zoneStatusImage.setImageNamed("watchZone2")
//                self.scoreZone2Cnt += 1
                
//                self.zoneStatus1LowTension = 0
//                self.zoneStatus2LowTension += 1
//                self.zoneStatusGoodjob = 0
//                self.zoneStatus4HighTension = 0
//                self.zoneStatus5HighTension = 0
                
//                //print("zone 2 \(self.scoreZone2Cnt)")
//                //print("zone 2 LowTension \(self.zoneStatus2LowTension)")
                
            case self!.userHeartRateZ3!..<self!.userHeartRateZ4!:
                self!.zoneStatus = "z3"
                self!.tensionZoneStatus = "zt3"
                self!.zoneStatusImage.setImageNamed("watchZone3")
//                self.scoreZone3Cnt += 1
                
                // 햅틱
//                if self.zoneStatusGoodjob == 1 {
//                    WKInterfaceDevice.current().play(.notification)
//                }
                
//                self.zoneStatus1LowTension = 0
//                self.zoneStatus2LowTension = 0
//                self.zoneStatusGoodjob += 1 // testZoneCheck
//                self.zoneStatus4HighTension = 0
//                self.zoneStatus5HighTension = 0
                
//                //print("zone 3 \(self.scoreZone3Cnt)")
//                //print("zone 3 Goodjob \(self.zoneStatusGoodjob)")
                
            case self!.userHeartRateZ4!..<self!.userHeartRateZ5!:
                self!.zoneStatus = "z4"
                self!.tensionZoneStatus = "zt4"
                self!.zoneStatusImage.setImageNamed("watchZone4")
//                self.scoreZone4Cnt += 1
                
//                self.zoneStatus1LowTension = 0
//                self.zoneStatus2LowTension = 0
//                self.zoneStatusGoodjob += 1
//                self.zoneStatus4HighTension += 1 // testZoneCheck
//                self.zoneStatus5HighTension = 0
                
//                //print("zone 4 \(self.scoreZone4Cnt)")
//                //print("zone 4 HighTension \(self.zoneStatus4HighTension)")
                
            case self!.userHeartRateZ5!..<999.99:
                self!.zoneStatus = "z5"
                self!.tensionZoneStatus = "zt5"
                self!.zoneStatusImage.setImageNamed("watchZone5")
//                self.scoreZone5Cnt += 1
                
//                self.zoneStatus1LowTension = 0
//                self.zoneStatus2LowTension = 0
//                self.zoneStatusGoodjob = 0
//                self.zoneStatus4HighTension += 1
//                self.zoneStatus5HighTension += 1 // testZoneCheck
                
//                //print("zone 5 \(self.scoreZone5Cnt)")
//                //print("zone 5 HighTension \(self.zoneStatus5HighTension)")
                
            default: break
                //print("not working")
            }
            
            
//            let scoreTimeStatus = self.scoreTime! % 120
//            //print("scoreTimeStatus : \(scoreTimeStatus)")
//            if scoreTimeStatus == 0 {
//                self.scoreResultTimer()
//            }
            
            //print(" scoreResultZone : \(self.scoreResultZone) ")
            
            let StringValueScoreResult = "\(self!.scoreResultZone)"
            
            //            심박수, 시간, 칼로리, 존구간, 점수
//            let msg = ["StringValueHeartRate" : "\(heartRateString)", "StringValueTimer": "\(self.timeFormatted(self.secsTime))", "StringValueKcalData" : "\(kcalDataSum)", "StringValueZoneStatus" : "\(self.zoneStatus)", "StringValueScoreResult": "\(StringValueScoreResult)"]
            let msg = ["StringValueHeartRate" : "\(heartRateString)", "StringValueTimer": "\(self!.timeFormatted(self!.secsTime))", "StringValueZoneStatus" : "\(self!.zoneStatus)", "StringValueScoreResult": "\(StringValueScoreResult)"]
            /*
            if !self!.fileManager.fileExists(atPath: directoryURL.path) {
                do {
                    try self!.fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
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
            
            // transferUserInfo test...
            self!.tryWatchSendMessage(message: msg as [String : Any])
            //self.wcSession!.transferUserInfo(msg)
            //self.wcSession!.sendMessage(msg, replyHandler: nil, errorHandler: {error in //print(error.localizedDescription)})
            
            self!.heartRateLabel.setText(heartRateString)
//            self.caloriWorkoutData.setText(kcalDataSum)
            self!.scoreTimeText.setText(StringValueScoreResult)
            
            self!.resultscoreTimer = StringValueScoreResult

            self!.resultEndTime = "\(self!.timeFormatted(self!.secsTime))"
        }
        
        
    }
    
    func tryWatchSendMessage(message: [String : Any]) {
        // 해당 구간이 에러 일 확률이 크다 추후에 수정해야할 것이다.
        // 해당 구간에 추가 분기 처리가 필요함.
        if WCSession.isSupported() {
           if self.wcSession != nil && self.wcSession?.activationState == .activated {
                   if self.wcSession?.isReachable == true {
                       self.wcSession?.sendMessage(message, replyHandler: { (reply: [String : Any]) -> Void in
                           //guard let result = reply["result"] else { return }
                           //print("InterfaceController reply result")
                           //print(result)
                           
                       }) { (error) -> Void in
                           // If the message failed to send, queue it up for future transfer
                           
                           if error == nil {
                               //print(" InterfaceController error : \(error)")
                               self.wcSession?.transferUserInfo(message)
                               //print(" InterfaceController transferUserInfo send \(message)")
                           }else {
                               print(" InterfaceController error : \(error)")
                               self.wcSession?.transferUserInfo(message)
                           }
                           
                       }
                   }
            } else if self.wcSession != nil && self.wcSession?.activationState == .inactive  {
                self.wcSession?.transferUserInfo(message)
            } else if let validSession = self.wcSession {
                //let data: [String: Any] = ["logincheck": "No" as Any]
                //UserDefaults.standard.set("No" , forKey: "logincheck")
                validSession.transferUserInfo(message)

            } else {
               self.wcSession?.transferUserInfo(message)
            }
                  
        }else {
            
        }
    }

    
    
}
