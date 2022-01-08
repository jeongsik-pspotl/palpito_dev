//
//  WorkoutViewController.swift
//  Palpito
//
//  Created by 김정식 on 12/12/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI
import WatchConnectivity
import AVFoundation
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
//import FirebaseFirestoreSwift

class WorkoutViewController: UIViewController, WCSessionDelegate {
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    var heartRateQuery: HKQuery?
    var heartRateSamples: [HKQuantitySample] = [HKQuantitySample]()
    var datasource: [HKQuantitySample] = []
    var configuration : HKWorkoutConfiguration?
    let healthStore = HKHealthStore()
    var wcSessionActivationCompletion : ((WCSession)->Void)?
    
    var resultWorkoutArray = [ResultWorkOut]()

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    weak var wcSession:WCSession?
    var mainQueue = DispatchQueue.global()
    var zoneSoundPlay: AVAudioPlayer?
    var zoneMusicPlay: AVAudioPlayer?
    var zoneStatusiOS = ""
    var checkZoneStatusSound = ""
    
    let today = Date()
    var resultSendToday:String = ""
    var timer = Timer()
    let soundDelay5 = 5.0
    let soundDelay20 = 20.0
    var startTimer = Timer()
    var secsTime = 0
    var getSescWatchTime = ""
    var isSoundChecked = true
    var isMusicChecked = true
    
    var resultHeartRate: String?
    var resultTotalCal: String?
    var resultTotalTime: String?
    var resultTotalScore: String?
    var resultMetersVal: String?
    
    var stageLevel:String = ""
    
    var languageCode = Locale.current.languageCode
    
    var paiplActiveAnimation: [UIImage] = []
    var palpiActiveAnimationZone2: [UIImage] = []
    var palpiActiveAnimationZone3: [UIImage] = []
    var palpiActiveAnimationZone4: [UIImage] = []
    var palpiActiveAnimationZone5: [UIImage] = []
    
    var ref : DatabaseReference! = Database.database().reference().child("user_exercise")
    var db : Firestore!

    @IBOutlet weak var heartRateText: UILabel!
    @IBOutlet weak var currentTimeText: UILabel!
    @IBOutlet weak var currentCalText: UILabel!
    @IBOutlet weak var zonePalpiImage: UIImageView!
    @IBOutlet weak var scoreResult: UILabel!
    @IBOutlet weak var myStageLevelImg: UIImageView!
    @IBOutlet weak var workoutView: UIView!
    
    @IBOutlet weak var palpiAnimationImage: UIImageView!
    @IBOutlet weak var palpiAnimationZone2: UIImageView!
    @IBOutlet weak var palpiAnimationZone3: UIImageView!
    @IBOutlet weak var palpiAnimationZone4: UIImageView!
    @IBOutlet weak var palpiAnimationZone5: UIImageView!
    
    @IBOutlet weak var msgLv1: UIImageView!
    @IBOutlet weak var msgLv2: UIImageView!
    @IBOutlet weak var msgLv3: UIImageView!
    @IBOutlet weak var msgLv4: UIImageView!
    @IBOutlet weak var msgLv5: UIImageView!
    
    deinit {
        //print("deinit workout view")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / workoutView.bounds.width
        
        workoutView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // today data Setting..
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.resultSendToday = dateFormatter.string(from: today)
        
        db = Firestore.firestore()

        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyStage")
//        request.returnsObjectsAsFaults = false
        
        // todayWorkOutCount 오늘 운동 카운트 세팅하기 조건부 1
        // todayDate 오늘 날짜 세팅 조건부 2
        
        // testing...
        let fetchRequest: NSFetchRequest<ResultWorkOut> = ResultWorkOut.fetchRequest()
        let predicate = NSPredicate(format: "todayDate == %@", self.resultSendToday)
        
        fetchRequest.predicate = predicate
        
        do {
            
            let resultWorkoutStatus = try PersistenceService.context.fetch(fetchRequest)
            self.resultWorkoutArray = resultWorkoutStatus
            
            //print("workoutViewController resultworkout count check... :  \(self.resultWorkoutArray.count)")
            
            for _ in resultWorkoutStatus as [NSManagedObject]
            {
                //print("resultworkout core data check... ")
                //print(result.value(forKey: "todayDate") as Any)
                
            }
            
//            let status = try PersistenceService.context.fetch(request)
//            //print(" core data status check.. : \(status.count)")
//            for data in status as! [NSManagedObject]
//            {
//                stageLevel = data.value(forKey: "stage") as! String
//            }
            
            
        } catch { }
        
        // 운동 강도 설정 체크
        if let myStage = UserDefaults.standard.string(forKey: "myStage"){
            self.stageLevel = myStage
        }else {
            UserDefaults.standard.set("SL2" , forKey: "myStage")
            self.stageLevel = "SL2"
        }
        
        if languageCode == "ko" {
            if self.stageLevel == "SL1" {
                myStageLevelImg.image = UIImage(named: "easyLevelText")

            } else if self.stageLevel == "SL2" {
                myStageLevelImg.image = UIImage(named: "middleLevelText")

            } else if self.stageLevel == "SL3" {
                myStageLevelImg.image = UIImage(named: "highLevelText")

            }

        } else {
            if self.stageLevel == "SL1" {
                myStageLevelImg.image = UIImage(named: "easyLevelTextEng")

            } else if self.stageLevel == "SL2" {
                myStageLevelImg.image = UIImage(named: "middleLevelTextEng")

            } else if self.stageLevel == "SL3" {
                myStageLevelImg.image = UIImage(named: "highLevelTextEng!")

            }

        }
                
        // 팔피 애니메이션 컷 세팅
        paiplActiveAnimation = createPalpiImage(total: 2, imagePrefix: "exerciseCharacter")
        palpiActiveAnimationZone2 = createPalpiImage(total: 2, imagePrefix: "exerciseCharacter")
        palpiActiveAnimationZone3 = createPalpiImage(total: 2, imagePrefix: "exerciseCharacter")
        palpiActiveAnimationZone4 = createPalpiImage(total: 2, imagePrefix: "exerciseCharacter")
        palpiActiveAnimationZone5 = createPalpiImage(total: 2, imagePrefix: "exerciseCharacter")
        
        // 구간별로 속도 수정하기
        animateZone1(imageView: palpiAnimationImage, images: paiplActiveAnimation)
        animateZone2(imageView: palpiAnimationZone2, images: palpiActiveAnimationZone2)
        animateZone3(imageView: palpiAnimationZone3, images: palpiActiveAnimationZone3)
        animateZone4(imageView: palpiAnimationZone4, images: palpiActiveAnimationZone4)
        animateZone5(imageView: palpiAnimationZone5, images: palpiActiveAnimationZone5)
        
        palpiAnimationZone2.stopAnimating()
        palpiAnimationZone3.stopAnimating()
        palpiAnimationZone4.stopAnimating()
        palpiAnimationZone5.stopAnimating()
        
        
        healthKitShared?.authorizeHealthKit { [weak self] (success, error) in
            //print("Was healthkit successful? \(success)")
            
            if success == true {
                self?.retrieveHeartRateData()
                self?.healthKitShared?.readMostRecentSample()
                
            }
            
            if error != nil {
                Crashlytics.crashlytics().record(error: error!)
            }
            
        }
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
            
        } catch {
            
            //print(error)
        }
        
        // Do any additional setup after loading the view.
    }
    
    // animation array setting
    func createPalpiImage(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray:[UIImage] = []
        
        for imageCount in 0..<total {
            
            let imageName = "\(imagePrefix)\(imageCount)"
            let image = UIImage(named: imageName)!
            
            imageArray.append(image)
        }
        
        return imageArray
    }
    
    // 구간별로 설정
    // 함수 분리하기
    func animateZone1(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 1.5
        imageView.startAnimating()
    }
    
    func animateZone2(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 1.0
        imageView.startAnimating()
    }
    
    func animateZone3(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 0.4
        imageView.startAnimating()
    }
    
    func animateZone4(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 0.2
        imageView.startAnimating()
    }
    
    func animateZone5(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 0.1
        imageView.startAnimating()
    }
    
    
    func animate(imageView: UIImageView, images:[UIImage]) {
        imageView.animationImages = images
        imageView.animationDuration = 1.0
        imageView.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
    }
    
    //Launches palpito app test..
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //session = nil
        // print("load did viewWillDisappear??")
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //session = nil
        // print("load did viewDidDisappear??")
    }
    
    func retrieveHeartRateData() {
        
        if let query = healthKitShared?.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            self.healthKitShared?.heartRateDelegate = self as HeartRateDelegate
            self.healthKitShared?.healthStore.execute(query)
        }
    }
    
    
    @IBAction func resultWorkoutVCAction(_ sender: Any) {
        
        // 애니메이션 로딩
        self.activityIndicator.startAnimating()
        
        if self.secsTime == 0 {
            let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ResultWorkoutViewController") as! ResultWorkoutViewController
            storyboard.modalPresentationStyle = .fullScreen
            
            self.present(storyboard, animated: true, completion: nil)
            
        }

        // 타이머 중지, 음악 중지
        startTimer.invalidate()
        self.zoneMusicPlay?.stop()
        self.zoneSoundPlay?.stop()
        //self.mainQueue.suspend()
        // 운동 결과 화면 이동 딜레이 적용!
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {

            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func startTimerfunc(){
        startTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        
        if secsTime  == 0 {
            let arrayWatchTimer = getSescWatchTime.components(separatedBy: ":")
            
            // 내부에 한번더 데이터 형변환 작업 하는 함수 기능 추가하기
            if Int(arrayWatchTimer[0]) != 0 {
                secsTime += Int(arrayWatchTimer[0])! * 3600
            } else if Int(arrayWatchTimer[1]) != 0  {
                secsTime += Int(arrayWatchTimer[1])! * 60
            } else if Int(arrayWatchTimer[2]) != 0 {
                secsTime = Int(arrayWatchTimer[2])!
            }
            
            secsTime += 1 // 시간 카운팅 임시 잠금 타이밍 맞추기 위해서
            
        }
        secsTime += 1
        self.currentTimeText.text = "\(timeFormatted(secsTime))"
        
    }
    
    func timeFormatted(_ totalSeconds:Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hour:Int = totalSeconds / 3600
        
        // 점수 산정을 위해 scoreTime 변수 저장
//        scoreTime = secsTime
        //        //print("scoreTime : \(String(describing: scoreTime))")
        return String(format: "%02d:%02d:%02d", hour, minutes, seconds)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // print("activationState : \(activationState)")
        // print("session : \(session)")
        print("error \(error as Any)")
        if(error != nil){
            Crashlytics.crashlytics().record(error: error!)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //print("sessionDidBecomeInactive : \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //print("WCSession : \(session)")
        //print("didReceiveMessage : \(message)")
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //print("WCSession : \(session)")
        //print("didReceiveMessage : \(message)")
        //print("replyHandler : \(String(describing: replyHandler))")
        
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    // userinfo, message type 두가지로 나눠서 분기 처리 if 조건문으로
    func updateUIData(message:[String: Any]){
        if let msg = message["StringValueHeartRate"] as? String {
            // print("message StringValueHeartRateMsg : \(msg)")
            self.heartRateText.text = "\(msg)"
        }

        if let kcalDataMsg = message["StringValueKcalData"] as? String {
            //print("message StringValueKcalDataMsg : \(kcalDataMsg)")
            self.currentCalText.text = "\(kcalDataMsg)"
        }
        
    }
    
    func dataHandlering(message:[String: Any]){
        // zone status
        if let zoneStatusMsg = message["StringValueZoneStatus"] as? String {
            //print("message StringValueZoneStatusMsg : \(zoneStatusMsg)")
            self.zoneStatusiOS = "\(zoneStatusMsg)"
        }

        if let scoreResultMsg = message["StringValueScoreResult"] as? String {
            //print("userInfo StringValueScoreResult : \(scoreResultMsg)")
            self.scoreResult.text = "\(scoreResultMsg)"
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.async {
            print(file)
            
            do {
                
                // 29일에 해당 구간 좀 더 구현할 방법 찾아보기
                // try fileManager.createDirectory(at: <#T##URL#>, withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[FileAttributeKey : Any]?#>)
                
                let strText = try String(contentsOf: file.fileURL, encoding: .utf8)
                
                print(strText)
                
            } catch let e {
                print(e.localizedDescription)
            }
            
        }
    }
    
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        
        // DispatchQueue.main start
        DispatchQueue.main.async {

            self.updateUIData(message: message);
            
            if let timerDataMsg = message["StringValueTimer"] {
                //print("userInfo StringValueTimer : \(timerDataMsg)")
                self.getSescWatchTime = "\(timerDataMsg)"
                // test!!
                if self.secsTime == 0 {
                // //print("secsTime time check.. ")
                // //print(self.secsTime)
                self.startTimerfunc()
                }
            }
            
            // zone 1 ~ 5 구간 마다 처리 결과 가저 오기 zoneStatusTensionVoice 비활성화
            // if zoneStatusTensionVoice start
            if let zoneStatusVoice = message["zoneStatusTensionVoice"] as? String {
                //print("userInfo zoneStatusTensionVoice : \(zoneStatusVoice)")
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        
                        if zoneStatusVoice == "zone1Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone2RecycleAction), userInfo: nil, repeats: false) // 피드백 수정

                        }
                        
                        if zoneStatusVoice == "zone2Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone2RecycleAction), userInfo: nil, repeats: false)

                        }
                        
                        //zone 3 구간만 격려 피드백 실행하기
                        if zoneStatusVoice == "zone3Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone3RecycleAction), userInfo: nil, repeats: false)

                        }
                        
                        if zoneStatusVoice == "zone4Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone3RecycleAction), userInfo: nil, repeats: false)

                        }
                        
                        if zoneStatusVoice == "zone5Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone45RecycleAction), userInfo: nil, repeats: false)

                        }
                    }
                }
                
                
            }
            // if zoneStatusTensionVoice end
            self.dataHandlering(message: message);
            
            //stopTimer
            if (message["stopTimer"] as? String) != nil {
                //print("message stopTimer : \(stopTimerDataMsg)")

                self.startTimer.invalidate()
            }

            

            // resultHeartRate, resultTotalCal, resultTotalTime, resultTotalScore 결과 데이터 전달 받음
            if let resultAvgHeartRateMsg = message["resultHeartRateVal"] as? String {
                //print("message resultHeartRateVal : \(resultAvgHeartRateMsg)")
                self.resultHeartRate = "\(resultAvgHeartRateMsg)"
            }

            if let kcalDataMsg = message["resultCalVal"] as? String {
                //print("message resultCalVal : \(kcalDataMsg)")
                self.resultTotalCal = "\(kcalDataMsg)"
            }

            if let timerDataMsg = message["resultEndTimeVal"] as? String {
                //print("message resultEndTimeVal : \(timerDataMsg)")
                self.resultTotalTime = "\(timerDataMsg)"
            }

            if let resultTotalScoreMsg = message["resultScoreCountVal"] as? String {
                //print("message resultScoreCountVal : \(resultTotalScoreMsg)")
                self.resultTotalScore = "\(resultTotalScoreMsg)"
            }

            // resultMetersVal
            if let resultMetersValMsg = message["resultMetersVal"] as? String {
                //print("message resultMetersVal : \(resultMetersValMsg)")
                self.resultMetersVal = "\(resultMetersValMsg)"
            }
            
            // if resultHeartRate start
            if self.resultHeartRate != nil {
                // 테스트 구간 ...
                // 실제 운동 링이 제로 일때 한번 테스트를 해봐야 할것이다..
                // 2021.3.28일에 소스 코드 작성해보고
                // 초기 테스트는 간단하 1분정도 쓰고 있다가
                // 잘되는지 확인해보고
                // 이상이 없으면
                // 밖에 나와서 테스트 진행하기..
                //self.activityIndicator.startAnimating()
                
                DispatchQueue.global().async {
                    //DispatchQueue.main.async {
                        
                        let ResultWorkOut = NSEntityDescription.entity(forEntityName: "ResultWorkOut", in: PersistenceService.context)
                        let newEntity = NSManagedObject(entity: ResultWorkOut!, insertInto: PersistenceService.context)

                        if self.resultTotalScore == nil || self.resultTotalScore == "" {
                            self.resultTotalScore = "0"
                        }else {
                            
                        }
                        
                        if self.resultTotalTime == "" {
                            self.resultTotalTime = "00:00:00"
                        }
                        // 운동 강도 데이터 저장 기능추가 해야함
                        // userLevel
        //                newEntity.setValue(self.stageLevel, forKey: "userLevel")
                        newEntity.setValue(self.resultHeartRate, forKey: "avgHeartRate")
                        newEntity.setValue(self.resultTotalTime, forKey: "totalWorkOutTime")
                        newEntity.setValue(self.resultTotalCal, forKey: "totalcalBurn")
                        newEntity.setValue(self.resultTotalScore, forKey: "totalScore")
                        newEntity.setValue(self.resultMetersVal, forKey: "avgSpeedHour")
                        newEntity.setValue(self.resultWorkoutArray.count + 1, forKey: "todayWorkOutCount")
                        newEntity.setValue(self.resultSendToday, forKey: "todayDate")

                        
                        
                        let user_exercise_key:String = self.ref.childByAutoId().key as Any as! String
                        
                        let data : [String : Any] = [
                                "uid" : Auth.auth().currentUser!.uid,
                                "user_exercise_key" : user_exercise_key,
                                "avg_heart_rate" : self.resultHeartRate!,
                                "user_level" : self.stageLevel,
                                "total_cal_burn" : self.resultTotalCal!,
                                "result_total_score" : Int(self.resultTotalScore!)! ,
                                "exercise_date" : self.resultSendToday,
                                "today_workout_count" : self.resultWorkoutArray.count + 1,
                                "result_total_time" : self.resultTotalTime!,
                                "result_send_today" : self.resultSendToday,
                                "result_meters" : ""

                        ]
                        
                        PersistenceService.saveContext()
                        
                        print("\(data)")
                        
                        // 테스트 이후에 삭제하기
                        self.db.collection("user_exercise").document(user_exercise_key).setData(data) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                Crashlytics.crashlytics().record(error: err)
                            } else {
                                
                                replyHandler!(["result":"success"])
                                
                                // print("Document successfully written!")
                                self.performSegue(withIdentifier: "resultWorkoutSegue", sender: self)
                                self.view.removeFromSuperview()
                                
                                


                            }
                        }

                        self.zoneMusicPlay?.stop()
                        self.zoneSoundPlay?.stop()

                        self.stageLevel = ""
                        
                        self.paiplActiveAnimation.removeAll()
                        self.palpiActiveAnimationZone2.removeAll()
                        self.palpiActiveAnimationZone3.removeAll()
                        self.palpiActiveAnimationZone4.removeAll()
                        self.palpiActiveAnimationZone5.removeAll()

                        // image view nil

                        self.resultHeartRate = nil
                        self.resultTotalTime = nil
                        self.resultTotalCal = nil
                        self.resultTotalScore = nil
                        self.resultMetersVal = nil
                        self.resultWorkoutArray.removeAll()
                        self.resultSendToday = ""
                        
                    //}
                    
                }
                
                
                //self.activityIndicator.stopAnimating()
                
            }
            // if resultHeartRate end
            
            // if zoneStatusiOS start
            switch self.zoneStatusiOS {

            case "z1":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi1")
                self.palpiAnimationImage.startAnimating()

                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationImage.isHidden = false

                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv1.isHidden = false

                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z2":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi2")
                self.palpiAnimationZone2.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone2.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv2.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z3":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi3")
                self.palpiAnimationZone3.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone3.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv3.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z4":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi4")
                self.palpiAnimationZone4.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone4.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv4.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv5.isHidden = true

            case "z5":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi5")
                self.palpiAnimationZone5.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()

                self.palpiAnimationZone5.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true

                self.msgLv5.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true

            default:
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi1")
                self.palpiAnimationImage.startAnimating()

                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationImage.isHidden = false

                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv1.isHidden = false

                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            }
            // if zoneStatusiOS start
            
            // if checkZoneStatusSound and zoneStatusiOS start
            if self.checkZoneStatusSound != self.zoneStatusiOS {
                self.checkZoneStatusSound = self.zoneStatusiOS
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                     
                    switch self.checkZoneStatusSound {
                        case "z1":
                            //print("warn up..")
                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone1SoundAction), userInfo: nil, repeats: false)

                        case "z2":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone2SoundAction), userInfo: nil, repeats: false)

                            // self.zone2MusicBGMAction()

                        case "z3":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone3SoundAction), userInfo: nil, repeats: false)

                            // self.zone3MusicBGMAction()


                        case "z4":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone4SoundAction), userInfo: nil, repeats: false)

                            // self.zone4MusicBGMAction()


                        case "z5":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone5SoundAction), userInfo: nil, repeats: false)

                            // self.zone5MusicBGMAction()


                        default:
                            print("not play..")
                        }
                    }
                }

            }
            // if checkZoneStatusSound and zoneStatusiOS start

          }
          // DispatchQueue.main end
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        
        DispatchQueue.main.async {
            
            if let msg = userInfo["StringValueHeartRate"] as? String {
                print("userInfo StringValueHeartRate : \(msg)")
                self.heartRateText.text = "\(msg)"
            }

            if let kcalDataMsg = userInfo["StringValueKcalData"] as? String {
                //print("userInfo StringValueKcalData : \(kcalDataMsg)")
                self.currentCalText.text = "\(kcalDataMsg)"
            }

            if let timerDataMsg = userInfo["StringValueTimer"] {
                //print("userInfo StringValueTimer : \(timerDataMsg)")
                self.getSescWatchTime = "\(timerDataMsg)"
                // test!!
                if self.secsTime == 0 {
//                    //print("secsTime time check.. ")
//                    //print(self.secsTime)
                    self.startTimerfunc()
                }
            }
            
            //stopTimer
            if (userInfo["stopTimer"] as? String) != nil {
                //print("userInfo stopTimer : \(stopTimerDataMsg)")
                self.zoneMusicPlay?.pause()
                self.zoneSoundPlay?.pause()

                self.startTimer.invalidate()
            }
            
            //resumeTimer
            if (userInfo["resumeTimer"] as? String) != nil {
                //print("userInfo resumeTimer : \(resumeTimerDataMsg)")
                self.zoneMusicPlay?.play()

                self.startTimerfunc()
            }

            if let zoneStatusMsg = userInfo["StringValueZoneStatus"] as? String {
                //print("userInfo StringValueZoneStatus : \(zoneStatusMsg)")
                self.zoneStatusiOS = "\(zoneStatusMsg)"
            }

            if let scoreResultMsg = userInfo["StringValueScoreResult"] as? String {
                //print("userInfo StringValueScoreResult : \(scoreResultMsg)")
                self.scoreResult.text = "\(scoreResultMsg)"
            }
            
            // zone 1 ~ 5 구간 마다 처리 결과 가저 오기 zoneStatusTensionVoice 기능 비활성화
            if let zoneStatusVoice = userInfo["zoneStatusTensionVoice"] as? String {
                //print("userInfo zoneStatusTensionVoice : \(zoneStatusVoice)")
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        
                        // zone 1 voice test
                        if zoneStatusVoice == "zone1Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone2RecycleAction), userInfo: nil, repeats: false)

                        }

                        if zoneStatusVoice == "zone2Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone2RecycleAction), userInfo: nil, repeats: false)

                        }

                        if zoneStatusVoice == "zone3Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone3RecycleAction), userInfo: nil, repeats: false)

                        }

                        if zoneStatusVoice == "zone4Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone3RecycleAction), userInfo: nil, repeats: false)

                        }
                        
                        if zoneStatusVoice == "zone5Voice" {
                            self.timer.invalidate()
                            self.timer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                #selector(self.zone45RecycleAction), userInfo: nil, repeats: false)

                        }
                    }
                }

            }
            
            if let resultAvgHeartRateMsg = userInfo["resultHeartRateVal"] as? String {
                //print("message resultHeartRateVal : \(resultAvgHeartRateMsg)")
                self.resultHeartRate = "\(resultAvgHeartRateMsg)"
            }

            if let kcalDataMsg = userInfo["resultCalVal"] as? String {
                //print("message resultCalVal : \(kcalDataMsg)")
                self.resultTotalCal = "\(kcalDataMsg)"
            }

            if let timerDataMsg = userInfo["resultEndTimeVal"] as? String {
                //print("message resultEndTimeVal : \(timerDataMsg)")
                self.resultTotalTime = "\(timerDataMsg)"
            }

            if let resultTotalScoreMsg = userInfo["resultScoreCountVal"] as? String {
                //print("message resultScoreCountVal : \(resultTotalScoreMsg)")
                self.resultTotalScore = "\(resultTotalScoreMsg)"
            }
            
            //resultMetersVal
            if let resultMetersValMsg = userInfo["resultMetersVal"] as? String {
                //print("message resultMetersVal : \(resultMetersValMsg)")
                self.resultMetersVal = "\(resultMetersValMsg)"
            }
            
            // if resultHeartRate start
            if self.resultHeartRate != nil {
                
                DispatchQueue.global().async {
                    //DispatchQueue.main.async {
                        
                        if self.resultTotalScore == nil || self.resultTotalScore == "" {
                            self.resultTotalScore = "0"
                        }else {
                            
                        }
                        
                        if self.resultTotalTime == "" {
                            self.resultTotalTime = "00:00:00"
                        }
                    
                        let ResultWorkOut = NSEntityDescription.entity(forEntityName: "ResultWorkOut", in: PersistenceService.context)
                        let newEntity = NSManagedObject(entity: ResultWorkOut!, insertInto: PersistenceService.context)
                        
                        // 운동 강도 데이터 저장 기능추가 해야함
                        newEntity.setValue(self.resultHeartRate, forKey: "avgHeartRate")
                        newEntity.setValue(self.resultTotalTime, forKey: "totalWorkOutTime")
                        newEntity.setValue(self.resultTotalCal, forKey: "totalcalBurn")
                        newEntity.setValue(self.resultTotalScore, forKey: "totalScore")
                        newEntity.setValue(self.resultMetersVal, forKey: "avgSpeedHour")
                        newEntity.setValue(self.resultWorkoutArray.count + 1, forKey: "todayWorkOutCount")
                        newEntity.setValue(self.resultSendToday, forKey: "todayDate")
                        
                        
                        PersistenceService.saveContext()

                        let user_exercise_key:String = self.ref.childByAutoId().key as Any as! String
                    
                        let data : [String : Any] = [
                                "uid" : Auth.auth().currentUser!.uid,
                                "user_exercise_key" : user_exercise_key,
                                "avg_heart_rate" : self.resultHeartRate!,
                                "user_level" : self.stageLevel,
                                "total_cal_burn" : self.resultTotalCal!,
                                "result_total_score" : Int(self.resultTotalScore!)!,
                                "exercise_date" : self.resultSendToday,
                                "today_workout_count" : self.resultWorkoutArray.count + 1,
                                "result_total_time" : self.resultTotalTime!,
                                "result_send_today" : self.resultSendToday,
                                "result_meters" : ""

                        ]
                        
                        

    //                self.ref.child(user_exercise_key).setValue(data, withCompletionBlock: {(error, ref) in
    //                    if let err = error {
    //                        //print(err.localizedDescription)
    //                    }
    //
    //                    self.ref.observe(.value, with: {(snapshot) in
    //                        guard snapshot.exists() else {
    //                            return
    //                        }
    //                        // 소스 코드 수정하기
    //                        self.performSegue(withIdentifier: "resultWorkoutSegue", sender: self)
    ////                        let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "ResultWorkoutViewController") as! ResultWorkoutViewController
    ////                        storyboard.modalPresentationStyle = .fullScreen

                            // 변경..
                            // self.navigationController!.pushViewController(storyboard, animated: true)
    //                        self.present(storyboard, animated: true, completion: nil)
    //                    })
    //                })
                        print("\(data)")
                        //Crashlytics.crashlytics().log(" result data \(data)")
                    // 테스트 이후에 삭제하기
                        self.db.collection("user_exercise").document(user_exercise_key).setData(data) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                Crashlytics.crashlytics().record(error: err)
                            } else {
                                // print("Document successfully written!")
                                self.performSegue(withIdentifier: "resultWorkoutSegue", sender: self)
                                self.view.removeFromSuperview()

                            }
                        }
                        
                        self.zoneMusicPlay?.stop()
                        self.zoneSoundPlay?.stop()

                        self.stageLevel = ""

                        self.activityIndicator.stopAnimating()
                        
                    }
                
                    
                //}

            }
            // if resultHeartRate end
            
            // switch  zoneStatusiOS start
            switch self.zoneStatusiOS {

            case "z1":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi1")
                self.palpiAnimationImage.startAnimating()

                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationImage.isHidden = false

                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv1.isHidden = false

                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z2":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi2")
                self.palpiAnimationZone2.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone2.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv2.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z3":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi3")
                self.palpiAnimationZone3.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone3.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv3.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            case "z4":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi4")
                self.palpiAnimationZone4.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationZone4.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv4.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv5.isHidden = true

            case "z5":
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi5")
                self.palpiAnimationZone5.startAnimating()

                self.palpiAnimationImage.stopAnimating()
                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()

                self.palpiAnimationZone5.isHidden = false

                self.palpiAnimationImage.isHidden = true
                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true

                self.msgLv5.isHidden = false

                self.msgLv1.isHidden = true
                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true

            default:
                self.zonePalpiImage.image = UIImage(named: "exercise-palpi1")
                self.palpiAnimationImage.startAnimating()

                self.palpiAnimationZone2.stopAnimating()
                self.palpiAnimationZone3.stopAnimating()
                self.palpiAnimationZone4.stopAnimating()
                self.palpiAnimationZone5.stopAnimating()

                self.palpiAnimationImage.isHidden = false

                self.palpiAnimationZone2.isHidden = true
                self.palpiAnimationZone3.isHidden = true
                self.palpiAnimationZone4.isHidden = true
                self.palpiAnimationZone5.isHidden = true

                self.msgLv1.isHidden = false

                self.msgLv2.isHidden = true
                self.msgLv3.isHidden = true
                self.msgLv4.isHidden = true
                self.msgLv5.isHidden = true

            }
            // switch  zoneStatusiOS start
            
            
            // if checkZoneStatusSound zoneStatusiOS  start
            if self.checkZoneStatusSound != self.zoneStatusiOS {
                self.checkZoneStatusSound = self.zoneStatusiOS
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        
                    switch self.checkZoneStatusSound {
                        case "z1":
                            //print("warn up..")
                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone1SoundAction), userInfo: nil, repeats: false)

                        case "z2":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone2SoundAction), userInfo: nil, repeats: false)

                            // self.zone2MusicBGMAction()

                        case "z3":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone3SoundAction), userInfo: nil, repeats: false)

                            // self.zone3MusicBGMAction()


                        case "z4":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone4SoundAction), userInfo: nil, repeats: false)

                            // self.zone4MusicBGMAction()


                        case "z5":

                            self.timer.invalidate()

                            self.timer  = Timer.scheduledTimer(timeInterval: self.soundDelay5, target: self, selector:
                                #selector(self.zone5SoundAction), userInfo: nil, repeats: false)

                            // self.zone5MusicBGMAction()


                        default: break
                            //print("not play..")
                        }
                    }
                }

            }
            // if checkZoneStatusSound zoneStatusiOS end
    
            
            //print("session userinfo call???? >>> end")
        }
    }

    
    
    
    @IBAction func soundTurnOnOffAction(_ sender: UIButton) {
        isSoundChecked = !isSoundChecked
        
        if isSoundChecked {
            self.zoneSoundPlay?.setVolume(5.0, fadeDuration: 2)
            sender.isSelected = false
            
        }else {
            self.zoneSoundPlay?.setVolume(0.0, fadeDuration: 2)
            sender.isSelected = true
            
        }
    }
    
    @IBAction func musicTurnOffAction(_ sender:UIButton) {
        isMusicChecked = !isMusicChecked
        
        if isMusicChecked {
            self.zoneMusicPlay?.setVolume(5.0, fadeDuration: 2)
            self.zoneMusicPlay?.play()
            sender.isSelected = false
            
        }else {
            self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 2)
            self.zoneMusicPlay?.pause()
            sender.isSelected = true
            
        }
        
    }
    
    @objc func zone1SoundAction() {
        
        if languageCode == "ko" {
           let path = Bundle.main.path(forResource: "zone1Recycle", ofType: "mp3")!
           let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }else {
          let path = Bundle.main.path(forResource: "zone1RecycleEng", ofType: "mp3")!
          let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
        
        
        
    }
    
    @objc func zone2SoundAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone2start", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }else {
            let path = Bundle.main.path(forResource: "zone2startEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
        
    }
    
    @objc func zone3SoundAction() {
        
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone3start", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }else {
            let path = Bundle.main.path(forResource: "zone3startEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
        
    }
    
    @objc func zone4SoundAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone4start", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        } else {
            let path = Bundle.main.path(forResource: "zone4startEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
            
        }
        
    }
    
    @objc func zone5SoundAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone5start", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        } else {
            let path = Bundle.main.path(forResource: "zone5startEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
        
    }
    
    // 기능 중지!
    @objc func zone1RecycleAction() {
        let path = Bundle.main.path(forResource: "zone1Recycle", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            
            if self.isSoundChecked == true {
                self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneSoundPlay?.play()
                //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            } else {
                self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneSoundPlay?.pause()
                //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            }
            
        } catch {
            //print("not play...")
        }
        
    }
    
    @objc func zone2RecycleAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone12Recycle", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        } else {
            let path = Bundle.main.path(forResource: "zone12RecycleEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
        
    }
    
    @objc func zone3RecycleAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone34Recycle", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        } else {
            let path = Bundle.main.path(forResource: "zone34RecycleEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
    }
    
    @objc func zone45RecycleAction() {
        if languageCode == "ko" {
            let path = Bundle.main.path(forResource: "zone45Recycle", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        } else {
            let path = Bundle.main.path(forResource: "zone45RecycleEng", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                
                if self.isSoundChecked == true {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.play()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                } else {
                    self.zoneSoundPlay = try AVAudioPlayer(contentsOf: url)
                    self.zoneSoundPlay?.pause()
                    //                self.zoneSoundPlay?.setVolume(15.0, fadeDuration: 0)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                    
                }
                
            } catch {
                //print("not play...")
            }
        }
    }
    
    func zone2MusicBGMAction(){
        let path = Bundle.main.path(forResource: "zone2_124bpmMusic", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            if self.isMusicChecked == true {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.play()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            }else {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.pause()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
            }
            
        } catch {
            //print("not play...")
        }
        
    }
    
    func zone3MusicBGMAction(){
        let path = Bundle.main.path(forResource: "zone3_130bpmMusic", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            if self.isMusicChecked == true {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.play()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            }else {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.pause()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
            }
            
        } catch {
            //print("not play...")
        }
        
    }
    
    func zone4MusicBGMAction(){
        let path = Bundle.main.path(forResource: "zone4_140bpmMusic", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            if self.isMusicChecked == true {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.play()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            }else {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.pause()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
            }
            
        } catch {
            //print("not play...")
        }
        
    }
    
    func zone5MusicBGMAction(){
        let path = Bundle.main.path(forResource: "zone5_160bpmMusic", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            if self.isMusicChecked == true {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.play()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
                
            }else {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.pause()
//                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
//                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.duckOthers])
            }
            
        } catch {
            //print("not play...")
        }
        
    }
}


extension WorkoutViewController: HeartRateDelegate {

    func heartRateUpdated(heartRateSamples: [HKSample]) {


    }
}


