//
//  AppDelegate.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 27/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData
import Firebase
import FirebaseAuth
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    override init() {
        
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
            //print("session activate AppDelegate")
            
            if session.isPaired != true {
                //print("Apple Watch is not paired")
            }else {
                //print("Apple Watch is paired")
                
            }
            
            if session.isWatchAppInstalled != true {
                //print("WatchKit app is not installed")
            }else {
                //print("WatchKit app is installed")
                
            }
        } else {
            //print("WatchConnectivity is not supported on this device")
        }
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
//        if WCSession.isSupported(){
//            let session = WCSession.default
//            session.delegate = self
//            session.activate()
//
//            //print("session activate AppDelegate")
//
//            if session.isPaired != true {
//                //print("Apple Watch is not paired")
//            }
//
//            if session.isWatchAppInstalled != true {
//                //print("WatchKit app is not installed")
//            }
//        } else {
//            //print("WatchConnectivity is not supported on this device")
//        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        if WCSession.isSupported(){
//            let session = WCSession.default
//            session.delegate = self
//            session.activate()
//
//            //print("session activate AppDelegate")
//
//            if session.isPaired != true {
//                //print("Apple Watch is not paired")
//            }
//
//            if session.isWatchAppInstalled != true {
//                //print("WatchKit app is not installed")
//            }
//        } else {
//            //print("WatchConnectivity is not supported on this device")
//        }
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
//        if WCSession.isSupported(){
//            let session = WCSession.default
//            session.delegate = self
//            session.activate()
//
//            //print("session activate AppDelegate")
//
//            if session.isPaired != true {
//                //print("Apple Watch is not paired")
//            }
//
//            if session.isWatchAppInstalled != true {
//                //print("WatchKit app is not installed")
//            }
//        } else {
//            //print("WatchConnectivity is not supported on this device")
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        if WCSession.isSupported(){
//            let session = WCSession.default
//            session.delegate = self
//            session.activate()
//
//            //print("session activate AppDelegate")
//
//            if session.isPaired != true {
//                //print("Apple Watch is not paired")
//            }
//
//            if session.isWatchAppInstalled != true {
//                //print("WatchKit app is not installed")
//            }
//        } else {
//            //print("WatchConnectivity is not supported on this device")
//        }
//
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PersistenceService.saveContext()
    }
    
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //print("url \(url)")
        //print("url host :\(url.host!)")
        //print("url path :\(url.path)")
        
//        let urlPath : String = url.path
//        let urlHost : String = url.host!
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
//
//        if urlHost != "palpito.xyz" {
//            //print("Host is not correct")
//            return false
//        }
//
//        if urlPath == "/workout" {
//            let workoutPage: WorkoutViewController = mainStoryboard.instantiateViewController(withIdentifier: "WorkoutViewController") as! WorkoutViewController
//            self.window?.rootViewController = workoutPage
//        } else if urlPath == "/abort" {
//
//        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
        // 워치os 상에 받는 함수..
        print("userInfo : \(String(describing: userInfo))")
        //print("reply    : \(String(describing: reply))")
        
    }
    
    
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("AppDelegate activationState : \(activationState)")
        //print("AppDelegate session : \(session)")
        //print("AppDelegate error \(error as Any)")
        if error != nil {
            Crashlytics.crashlytics().record(error: error!)
        }
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //print("sessionDidDeactivate : \(session)")
    }
    
    // 백그라운드 작업이 이걸로 안될 수 있음 그래서 소스를 조금 뒤집어야함.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlesSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handlesSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    func handlesSession(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
        
        DispatchQueue.main.async {
            if (message["StartWorkoutCall"] as? String) != nil {
                //print(" StartWorkoutCall msg : \(msg)")
                let readyWorkoutPage: ReadyWorkoutViewController = mainStoryboard.instantiateViewController(withIdentifier: "ReadyWorkoutViewController") as! ReadyWorkoutViewController
                self.window?.rootViewController = readyWorkoutPage
                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
            }
            
//            if (message["StartRelaxCall"] as? String) != nil {
//                //print(" StartRelaxCall msg : \(msg)")
//                let relaxPage: RelaxViewController = mainStoryboard.instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
//                self.window?.rootViewController = relaxPage
//                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
//            }
            
            
            if (message["resultEndTimeVal"] as? String) != nil {
                //print(" resultEndTimer msg : \(msg)")
                let resultWorkoutPage: ResultWorkoutViewController = mainStoryboard.instantiateViewController(withIdentifier: "ResultWorkoutViewController") as! ResultWorkoutViewController
                self.window?.rootViewController = resultWorkoutPage
                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
            }
            
//            if (message["resultRelaxEndTimeVal"] as? String) != nil {
//                //print(" resultRelaxEndTimeVal msg : \(msg)")
//                let resultRelaxPage: ResultRelaxViewController = mainStoryboard.instantiateViewController(withIdentifier: "ResultRelaxViewController") as! ResultRelaxViewController
//                self.window?.rootViewController = resultRelaxPage
//                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
//            }
            
//            if let msg = message["MyStageLvl"] as? String {
//                 UserDefaults.standard.set(msg, forKey: "myStage")
//            }
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "StartApp", bundle: nil)
        
        DispatchQueue.main.async {
            if (userInfo["StartWorkoutCall"] as? String) != nil {
                //print(" StringValueHeartRate msg : \(msg)")
                
                let readyWorkoutPage: WorkoutViewController = mainStoryboard.instantiateViewController(withIdentifier: "WorkoutViewController") as! WorkoutViewController
                self.window?.rootViewController = readyWorkoutPage
                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
            }
            
//            if (userInfo["StartRelaxCall"] as? String) != nil {
//                //print(" StartRelaxCall msg : \(msg)")
//
//                let relaxPage: RelaxViewController = mainStoryboard.instantiateViewController(withIdentifier: "RelaxViewController") as! RelaxViewController
//                self.window?.rootViewController = relaxPage
//                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
//            }
            
            if let heartRateVal = userInfo["StringValueHeartRate"] as? String {
                
                print(" appDelegate | StringValueHeartRate | heartRateVal : \(heartRateVal) ")
                
            }
            
            //resultEndTimer
            if (userInfo["resultEndTimeVal"] as? String) != nil {
                //print(" resultEndTimer msg : \(msg)")
                let resultWorkoutPage: ResultWorkoutViewController = mainStoryboard.instantiateViewController(withIdentifier: "ResultWorkoutViewController") as! ResultWorkoutViewController
                self.window?.rootViewController = resultWorkoutPage
                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
            }
            
//            if (userInfo["resultRelaxEndTimeVal"] as? String) != nil {
//                //print(" resultRelaxEndTimeVal msg : \(msg)")
//                let resultRelaxPage: ResultRelaxViewController = mainStoryboard.instantiateViewController(withIdentifier: "ResultRelaxViewController") as! ResultRelaxViewController
//                self.window?.rootViewController = resultRelaxPage
//                //            //print("AppDelegate data check | message StringValueHeartRate : \(msg)")
//            }
            
        }
        
    }
    
}

