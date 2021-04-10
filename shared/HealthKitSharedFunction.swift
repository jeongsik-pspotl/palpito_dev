//
//  File.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 31/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import Foundation
import HealthKit



protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

protocol MeterDataDelegate {
    func meterDataUpdated(meterDataSamples: [HKSample])
}

protocol ActiveEnergyBurnedDelegate {
    func activeEnergyBurnedDelegate(activeEnergyBurned: [HKSample])
}

class HealthKitSharedFunction: NSObject {
    
    static let sharedInstance = HealthKitSharedFunction()

    let healthStore = HKHealthStore()
    
    private override init(){}
    
    var anchor: HKQueryAnchor?
    
    var heartRateDelegate: HeartRateDelegate?
    
    var meterDataDelegate: MeterDataDelegate?
    
    var activeEnergyBurnedDelegate: ActiveEnergyBurnedDelegate?
    
    var mainColWeightText:String = ""
    
    var mainColWeightInt: Double = 0.0
    
    var mainAvgHeartRate:String = ""
    
    var mainRestingHeartRate:String = ""
    
    var mainAvgMeters:String = ""
    
    var todayAvgHeartRate:String = ""
    
    var todayActiveEnergyBurned:String = ""
    
    var todayActiveEnergyBurnedGoal:String = ""
    
    final let bpmRatefun = 220
    
    func authorizeHealthKit(_ completion: @escaping ((_ success:Bool, _ error: Error?)-> Void)){
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        guard let restingHeartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        guard let walkRunningType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        
        guard let bodyMassPercentage = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else{
            return
        }
        
        let activitySummaryType = HKActivitySummaryType.activitySummaryType()

        //print(" healthStore check... : ")

        let typesToShare = Set([HKObjectType.workoutType(),
                                                heartRateType,
                                                restingHeartRateType,
                                                walkRunningType])
        
        let typesToRead = Set([HKObjectType.workoutType(),
                                              heartRateType,
                                              restingHeartRateType,
                                              walkRunningType,
                                              HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                              HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                              HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                                              bodyMassPercentage,
                                              activitySummaryType])
        
        
        if !HKHealthStore.isHealthDataAvailable(){
            //print("Error occured")
            return
        }
        
        // weak self [] 첨부
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead ) { (success, error) -> Void in
                //print("Was authorization successful? \(success)")
                completion(success, error)
        }
        
    }
    
    // heartRate Query
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            
            if(error != nil){
                
            }else {
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                self.anchor = newAnchor
                self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
            }
            
        }
        
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            if(error != nil){
                
            }else {
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                self.anchor = newAnchor
                self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
            }
            
        }
        
        return heartRateQuery
    }
    
    // activeEnergyBurned Query
    func createActiveEnergyBurnedStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let activeEnergyBurnedType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: activeEnergyBurnedType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            if(error != nil){
                
            }else {
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                self.anchor = newAnchor
                self.activeEnergyBurnedDelegate?.activeEnergyBurnedDelegate(activeEnergyBurned: sampleObjects)
            }
            
        }
        
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            if(error != nil){
                
            }else {
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                self.anchor = newAnchor
                self.activeEnergyBurnedDelegate?.activeEnergyBurnedDelegate(activeEnergyBurned: sampleObjects)
            }
            
        }
        
        return heartRateQuery
    }
    
    // walkingRunning Query data testing...
    func createWalkingRunningStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let walkRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let walkRunningQuery = HKAnchoredObjectQuery(type: walkRunningType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            if(error != nil){
                
            }else {
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                self.anchor = newAnchor
                self.meterDataDelegate?.meterDataUpdated(meterDataSamples: sampleObjects)
            }
            
        }
        
        walkRunningQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            if(error != nil){
                
            }else{
                guard let newAnchor = newAnchor,
                    let sampleObjects = sampleObjects else {
                        return
                }
                
                // weak self [] 첨부 하기
                self.anchor = newAnchor
                self.meterDataDelegate?.meterDataUpdated(meterDataSamples: sampleObjects)
            }
            
        }
        
        return walkRunningQuery
        
    }
    
    // Avg heartRate
    func getAVGHeartRate(_ workResultDate: Date) -> String{
        
        var getHeartBeats = ""
        
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .heartRate)
        // var startDate = Date() - 7 * 24 * 60 * 60 // start date is a week as-is
        
        let resultDate = workResultDate // start date to-be
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: resultDate, end: Date(), options: HKQueryOptions.strictEndDate)
        
        let squery = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            if(error != nil){
                
            }else {
                let quantity: HKQuantity? = result?.averageQuantity()
                let beats: Double? = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                //print("got: \(String(format: "%.f", beats!))")
                getHeartBeats = "\(String(format: "%.f", beats!))"
                self.mainAvgHeartRate = getHeartBeats
            }
                

        })
        healthStore.execute(squery)
        return getHeartBeats
    }
    
    
    
    // Avg WalkingRunning
    func getAVGWalkingRunning(_ workResultDate: Date) -> String{
        
        var getMeters = ""
        
        let walkRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        // var startDate = Date() - 7 * 24 * 60 * 60 // start date is a week as-is
        
        let resultDate = workResultDate // start date to-be
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: resultDate, end: Date(), options: .strictStartDate)
        
        let squery = HKStatisticsQuery(quantityType: walkRunningType!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            
            if(error != nil){
                
            }else {
                //print("result data check... ")
                //print(result?.averageQuantity())
                let quantity: HKQuantity? = result?.sumQuantity()
    //            let beats: Double? = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let meters: Double? = quantity?.doubleValue(for: HKUnit.meter().unitDivided(by: HKUnit.hour()))
                //print("meter: \(String(format: "%.f", meters!))")
                getMeters = "\(String(format: "%.f", meters!))"
                self.mainAvgMeters = getMeters
            }
            
            
        })
        healthStore.execute(squery)
        return getMeters
    }
    
    func getReadablebloodType(bloodType:HKBloodType?)->String
    {
        var bloodTypeText = ""
        
        if bloodType != nil {
            switch (bloodType!) {
                case .aPositive:
                        bloodTypeText = "A+"
                case .aNegative:
                        bloodTypeText = "A-"
                case .bPositive:
                        bloodTypeText = "B+"
                case .bNegative:
                        bloodTypeText = "B-"
                case .abPositive:
                        bloodTypeText = "AB+"
                case .abNegative:
                        bloodTypeText = "AB-"
                case .oPositive:
                        bloodTypeText = "O+"
                case .oNegative:
                        bloodTypeText = "O-"
                default:
                        break;
            }
        }
        return bloodTypeText
    }
    
    func readProfile() -> (age:Int?, bloodtype:HKBloodTypeObject?)
    {
        var age:Int?
        var bloodType:HKBloodTypeObject?
        
//        //print("start readProfile... ")
        do{
            let birthDay = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentyear = calendar.component(.year, from: Date())
            age = currentyear - birthDay.year!
//            //print("age check ... \(String(describing: age))")
            
        } catch { }
        
        do {
            bloodType = try healthStore.bloodType()
            
        } catch{ }
        
        return (age, bloodType)
    }
    
    func writeToKit(weightVal:Int){
        let weight = weightVal
        
        let today = NSDate()
        if let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass){
            
            let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: Double(weight))
            
            let sample = HKQuantitySample(type: type, quantity: quantity, start: today as Date, end: today as Date)
            healthStore.save(sample) { (success, error) in
                //print("Saved \(success), error \(String(describing: error))")
            }
        }
    }
    
    func readMostRecentSample()
    {
        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
//        //print("weightType .. data check ..  \(weightType)")
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, result, error) in
                
            if(error != nil){
                
            }else {
                //print("weightType .. data check ..  \(result?.last)")
                if let sample = result?.last as? HKQuantitySample{
                    
                    //print("weight in => \(sample.quantity)")
                    DispatchQueue.main.async(execute: { () -> Void in
                        //print("weight in => \(sample.quantity.doubleValue(for: HKUnit(from: "kg")))")
                        //print("weight in => \(sample.quantity)")
                        self.mainColWeightInt = sample.quantity.doubleValue(for: HKUnit(from: "kg"))
                        self.mainColWeightText = "\(sample.quantity)"
                    })
                    
                } else {
                    //print("result data => \(String(describing: result))   \n error data \(String(describing: error))")
                    
                }
            
            }
                
        }
        healthStore.execute(query)
    }
    
    func readTodayAvgHeartRate() {
        let todayAvgHeartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictEndDate)
        
        let sampleQuery = HKStatisticsQuery(quantityType: todayAvgHeartRateType!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            if(error != nil){
                
            }else {
                guard let result = result, let avg = result.averageQuantity() else {
                    return
                }
                
                let avgHeartRate = avg.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                //print("avgHeartRate : \(String(format: "%.f", avgHeartRate))")
                self.todayAvgHeartRate = "\(String(format: "%.f", avgHeartRate))"
            }
            
            
        })
        
        healthStore.execute(sampleQuery)
        
    }
    
    // rest heartRate
    func getRestHeartRate() {
        
        
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
        // var startDate = Date() - 7 * 24 * 60 * 60 // start date is a week as-is
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictEndDate)
        
        let squery = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            
            guard let result = result, let avg = result.averageQuantity() else {
                return
            }
            
            let restingHeartRate = avg.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            //print("restingHeartRate : \(String(format: "%.f", restingHeartRate))")
            self.mainRestingHeartRate = "\(String(format: "%.f", restingHeartRate))"
            
        })
        healthStore.execute(squery)
        
    }
    
    func getActivitySummaryEnergyBurnedGoal() {
        
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            if(error != nil){
                
            }else {
                for summary in summaries! {
                    
                    if(summary != nil){
                        let activeEnergyBurned = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                        let activeEnergyBurnedGoal = summary.activeEnergyBurnedGoal.doubleValue(for: HKUnit.kilocalorie())
                        
                        self.todayActiveEnergyBurned = "\(String(format: "%.f", activeEnergyBurned))"
                        self.todayActiveEnergyBurnedGoal = "\(String(format: "%.f", activeEnergyBurnedGoal))"
                    }else {
                        self.todayActiveEnergyBurned = "0"
                        self.todayActiveEnergyBurnedGoal = "0"
                    }
                    
    //                let activeEnergyBurnGoalPercent = round(activeEnergyBurned/activeEnergyBurnedGoal)
                    
                    //print("activeEnergyBurned")
                    //print(activeEnergyBurned)
                    //print("activeEnergyBurnedGoal")
                    //print(activeEnergyBurnedGoal)
                    
                    
                }
            }
            
        }
        
        healthStore.execute(query)
    }
}
    

