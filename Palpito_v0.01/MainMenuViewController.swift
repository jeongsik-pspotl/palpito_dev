//
//  MainMenuViewController.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 17/10/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var heartRateTableView: UITableView!
    
    @IBOutlet weak var userRateData: UILabel!
    
    @IBOutlet weak var userAgeLabel: UILabel!
    
    @IBOutlet weak var weightText: UILabel!
    
    let healthKitShared = HealthKitSharedFunction.sharedInstance
    
    var datasource: [HKQuantitySample] = []
    
    var heartRateQuery: HKQuery?
    
    var healthStore = HKHealthStore()
    
    final let bpmRate = 220
    
    var changeBpmRate = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        
        healthKitShared.authorizeHealthKit { (success, error) in
            //print("Was healthkit successful? \(success)")
            self.retrieveHeartRateData()
            self.healthKitShared.readMostRecentSample()
        }
    }
    
    func retrieveHeartRateData() {
        
//        self.changeBpmRate = self.bpmRate
//        self.userRateData.text = "\(Double(self.changeBpmRate - 32) * 0.8)"
        
        if let query = healthKitShared.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            self.healthKitShared.heartRateDelegate = self
            self.healthKitShared.healthStore.execute(query)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        //print("delete id, pwd")
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey: "pwd")
        
        //StartViewSb
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "StartViewSb")
        nextView.modalPresentationStyle = .fullScreen
        //self.modalPresentationStyle = .fullScreen
        present(nextView, animated: true, completion: nil)
        
    }
    @IBAction func accessHealthKitAction(_ sender: Any) {
        
        healthKitShared.authorizeHealthKit { (success, error) in
            //print("Was healthkit successful? \(success)")
            self.retrieveHeartRateData()
            
        }
        
        
        self.changeBpmRate = self.bpmRate
        
        
        
        let (age, bloodtype) = self.healthKitShared.readProfile()
//        self.healthKitShared.writeToKit(weightVal: 5888)
//        //print("\(String(describing: age!))")
//        //print("data call check ... : \(self.healthKitShared.mainColWeightText)")
        self.userAgeLabel.text = "\(String(describing: age!))"
        self.weightText.text = "\(self.healthKitShared.mainColWeightText)"
        self.userRateData.text = "\(Double(self.changeBpmRate - age!) * 0.8)"
        
//        //print("text data check ... : \(self.healthKitShared.mainColWeightText)")
//        self.weightText.text = self.healthKitShared.mainColWeightText
//        self.healthKitShared.readMostRecentSample()
//        self.weightText.text = "\(String(describing: bodyFat?.description))"
//        //print("userAgeLabel ... \(String(describing: age!))")
//        //print("bloodtype ... \(String(describing: bloodtype!))")
//        //print("bodyFat ... \(String(describing: bodyFat!))")
        
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

extension MainMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath)
        cell.textLabel?.text = "\(datasource[indexPath.row].quantity)"
        return cell
    }
}

extension MainMenuViewController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            
            self.datasource.append(contentsOf: heartRateSamples)
//            self.heartRateTableView
            self.heartRateTableView.reloadData()
        }
    }
}
