//
//  RelaxViewController.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 23/05/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI
import WatchConnectivity
import AVFoundation
import CoreData

class RelaxViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var palpiAnimationImg: UIImageView!
    @IBOutlet weak var relaxHeartRateLabel: UILabel!
    @IBOutlet weak var relaxPlayTime: UILabel!
    
    @IBOutlet weak var relaxView: UIView!
    
    weak var healthKitShared = HealthKitSharedFunction.sharedInstance
    
    var heartRateQuery: HKQuery?
    var heartRateSamples: [HKQuantitySample] = [HKQuantitySample]()
    let healthStore = HKHealthStore()
    
    var resultRelaxArray = [ResultRelax]()
    
    weak var session = WCSession.default
    var zoneMusicPlay: AVAudioPlayer?
    
    var relaxStatusiOS = "off"
    var checkrelaxStatusSound = "off"
    
    let today = Date()
    var resultSendToday:String = ""
    var timer = Timer()
    var startTimer = Timer()
    var secsTime = 0
    var getSescWatchTime = ""
    var isMusicChecked = true
    
    var resultHeartRate: String?
    var resultTotalTime: String?
    
    var paiplActiveAnimation: [UIImage] = []
    
    deinit {
        //print("deinit relax view")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / relaxView.bounds.width

        relaxView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // today data Setting..
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.resultSendToday = dateFormatter.string(from: today)

        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
        let fetchRequest: NSFetchRequest<ResultRelax> = ResultRelax.fetchRequest()
        let predicate = NSPredicate(format: "todayDate == %@", self.resultSendToday)
        
        fetchRequest.predicate = predicate
        
        do {
            
            let resultRelaxStatus = try PersistenceService.context.fetch(fetchRequest)
            self.resultRelaxArray = resultRelaxStatus
            
            //print("workoutViewController resultworkout count check... :  \(self.resultRelaxArray.count)")
            
            for _ in resultRelaxArray as [NSManagedObject]
            {
                //print("resultRelax core data check... ")
                //print(result.value(forKey: "todayDate") as Any)
                
            }
            
            
        } catch { }
        
        paiplActiveAnimation = createPalpiImage(total: 2, imagePrefix: "relaxCharacter")
        
        animate(imageView: palpiAnimationImg, images: paiplActiveAnimation)
        
        healthKitShared?.authorizeHealthKit { [weak self] (success, error) in
            //print("Was healthkit successful? \(success)")
            
            if success == true {
                self?.retrieveHeartRateData()
                self?.healthKitShared?.readMostRecentSample()
                
            }
            
        }
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
            
        } catch {
            
            //print(error)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
            
            //print("session activate")
        } else {
            //print("session error")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
    }
    
    // animation array setting
    func createPalpiImage(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray:[UIImage] = []
        
        for imageCount in 0..<total {
            
            let imageName = "\(imagePrefix)\(imageCount)iOS"
            let image = UIImage(named: imageName)!
            
            imageArray.append(image)
        }
        
        return imageArray
    }
    
    func animate(imageView: UIImageView, images:[UIImage]) {
        imageView.animationImages = images
        imageView.animationDuration = 2.0
        imageView.startAnimating()
        
    }
    
    func retrieveHeartRateData() {
        
        if let query = healthKitShared?.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            self.healthKitShared?.heartRateDelegate = self
            self.healthKitShared?.healthStore.execute(query)
        }
    }
    
    @IBAction func relaxMusicOnOffAction(_ sender: UIButton) {
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
        self.relaxPlayTime.text = "\(timeFormatted(secsTime))"
        
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
    
    func relaxMusicBGMAction(){
        let path = Bundle.main.path(forResource: "relaxMusic", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            if self.isMusicChecked == true {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.play()
                //                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
                //                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                
            }else {
                self.zoneMusicPlay = try AVAudioPlayer(contentsOf: url)
                self.zoneMusicPlay?.pause()
                //                self.zoneMusicPlay?.setVolume(0.0, fadeDuration: 0)
                //                self.zoneMusicPlay?.setVolume(15.0, fadeDuration: 7)
                self.zoneMusicPlay?.numberOfLoops = -1 // 임시 반복 기능... 추후에 수정 필요
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
            }
            
        } catch {
            //print("not play...")
        }
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        DispatchQueue.main.async {
            
            if let msg = message["RelaxStringValueHeartRate"] as? String {
                //print("message RelaxStringValueHeartRate : \(msg)")
                self.relaxHeartRateLabel.text = "\(msg)"
                
            }
            
            //stopRelaxTimer
            if (message["stopRelaxTimer"] as? String) != nil {
                //print("message stopTimer : \(stopTimerDataMsg)")
                
                self.startTimer.invalidate()
            }
            
            // RelaxStringValueZoneStatus
            if let relaxStatusMsg = message["RelaxStringValueZoneStatus"] as? String {
                //print("userInfo RelaxStringValueZoneStatus : \(relaxStatusMsg)")
                self.relaxStatusiOS = "\(relaxStatusMsg)"
            }
            
            if let resultRelaxHeartRateMsg = message["resultRelaxHeartRateVal"] as? String {
                //print("message resultRelaxHeartRateVal : \(resultRelaxHeartRateMsg)")
                self.resultHeartRate = "\(resultRelaxHeartRateMsg)"
            }
            
            if let resultRelaxEndTimeMsg = message["resultRelaxEndTimeVal"] as? String {
                //print("message resultRelaxEndTimeVal : \(resultRelaxEndTimeMsg)")
                self.resultTotalTime = "\(resultRelaxEndTimeMsg)"
            }
            
            if self.resultHeartRate != nil {
                
                let ResultRelax = NSEntityDescription.entity(forEntityName: "ResultRelax", in: PersistenceService.context)
                let newEntity = NSManagedObject(entity: ResultRelax!, insertInto: PersistenceService.context)
                
                // relaxType, todayRelaxCount
                newEntity.setValue(self.resultHeartRate, forKey: "avgHeartRate")
                newEntity.setValue(self.resultTotalTime, forKey: "totalRelaxTime")
                newEntity.setValue(self.resultSendToday, forKey: "todayDate")
                newEntity.setValue(self.resultRelaxArray.count + 1, forKey: "todayRelaxCount")
                newEntity.setValue("RE1", forKey: "relaxType")
                
                PersistenceService.saveContext()
                
                self.zoneMusicPlay?.stop()
                
                self.performSegue(withIdentifier: "resultRelaxSegue", sender: self)
                
                self.paiplActiveAnimation.removeAll()
                
                self.resultHeartRate = nil
                self.resultTotalTime = nil
                self.resultSendToday = ""
                
            }
            
            if self.checkrelaxStatusSound == self.relaxStatusiOS {
                
                self.relaxMusicBGMAction()
                
            }else {
                
                
            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            
            if let msg = userInfo["RelaxStringValueHeartRate"] as? String {
                //print("userInfo RelaxStringValueHeartRate : \(msg)")
                self.relaxHeartRateLabel.text = "\(msg)"
                
            }
            
            if let timerDataMsg = userInfo["RelaxStringValueTimer"] as? String {
                //print("userInfo RelaxStringValueTimer : \(timerDataMsg)")
                self.getSescWatchTime = "\(timerDataMsg)"
                // test!!
                if self.secsTime == 0 {
                    //                    //print("secsTime time check.. ")
                    //                    //print(self.secsTime)
                    self.startTimerfunc()
                }
            }
            
            // stopTimer
            if (userInfo["stopRelaxTimer"] as? String) != nil {
                //print("userInfo stopRelaxTimer : \(stopTimerDataMsg)")
                self.zoneMusicPlay?.pause()
                
                self.startTimer.invalidate()
            }
            
            // RelaxStringValueZoneStatus
            if let relaxStatusMsg = userInfo["RelaxStringValueZoneStatus"] as? String {
                //print("userInfo RelaxStringValueZoneStatus : \(relaxStatusMsg)")
                self.relaxStatusiOS = "\(relaxStatusMsg)"
            }
            
            // resumeTimer
            if (userInfo["resumeRelaxTimer"] as? String) != nil {
                //print("userInfo resumeRelaxTimer : \(resumeTimerDataMsg)")
                self.zoneMusicPlay?.play()
                
                self.startTimerfunc()
            }
            
            if let resultRelaxHeartRateMsg = userInfo["resultRelaxHeartRateVal"] as? String {
                //print("message resultRelaxHeartRateVal : \(resultRelaxHeartRateMsg)")
                self.resultHeartRate = "\(resultRelaxHeartRateMsg)"
            }
            
            if let resultRelaxEndTimeMsg = userInfo["resultRelaxEndTimeVal"] as? String {
                //print("message resultRelaxEndTimeVal : \(resultRelaxEndTimeMsg)")
                self.resultTotalTime = "\(resultRelaxEndTimeMsg)"
            }
            
            if self.resultHeartRate != nil {
                
                let ResultRelax = NSEntityDescription.entity(forEntityName: "ResultRelax", in: PersistenceService.context)
                let newEntity = NSManagedObject(entity: ResultRelax!, insertInto: PersistenceService.context)
                
                // relaxType, todayRelaxCount
                newEntity.setValue(self.resultHeartRate, forKey: "avgHeartRate")
                newEntity.setValue(self.resultTotalTime, forKey: "totalRelaxTime")
                newEntity.setValue(self.resultSendToday, forKey: "todayDate")
                newEntity.setValue(self.resultRelaxArray.count + 1, forKey: "todayRelaxCount")
                newEntity.setValue("RE1", forKey: "relaxType")
                
                PersistenceService.saveContext()
                
                self.zoneMusicPlay?.stop()
                self.performSegue(withIdentifier: "resultRelaxSegue", sender: self)
                
                
            }
            
            if self.checkrelaxStatusSound == self.relaxStatusiOS {
                    
                self.relaxMusicBGMAction()
                
            }else {
                
                
            }
            
            //self.relaxMusicBGMAction() 새로운 기능 추가
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RelaxViewController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
        
    }
}
