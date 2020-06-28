//
//  ExtensionDelegate.swift
//  Palpito_watchOS Extension
//
//  Created by 김정식 on 31/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    weak var session = WCSession.default
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("=== ExtensionDelegate .. ======")
        //print("session WCSession : \(session)")
        //print("activationState WCSessionActivationState : \(activationState)")
        //print("error Error : \(String(describing: error))")
    }
    

    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        
    }
    
    func applicationDidEnterBackground() {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        
    }
    
    func applicationWillEnterForeground() {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        
    }

    func applicationDidBecomeActive() {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        
    }

    func applicationWillResignActive() {
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
