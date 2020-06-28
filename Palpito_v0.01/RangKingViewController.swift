//
//  RangKingViewController.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/31.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RangKingViewController: UITableViewController {
    
    var list = [Dictionary<String, AnyObject>]()
    
    var ref: DatabaseReference!
    
    var startPoint = 0
    
    @IBOutlet var tableViewRangKing: UITableView!
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        
        self.callTheaterAPI()
        
        tableViewRangKing.delegate = self
        tableViewRangKing.dataSource = self
        
        
    }
    
    func callTheaterAPI(){
        
        // self.ref.child("user_info")
        // 해당 부분 fire base 기반 전환
        
        self.ref.child("user_info").observe(.value, with: {
            (userSnapShot) in

            guard let allObjects = userSnapShot.children.allObjects as? [DataSnapshot] else { return }

            allObjects.forEach { (allUsersnapShot) in
                let userKey = allUsersnapShot.key as String
                let user_nick_name:String = allUsersnapShot.childSnapshot(forPath: "nick_name").value as Any as! String
                
                //print("userKey \(userKey)")
                //print("user_nick_name \(String(describing: user_nick_name))")
                
                self.ref.child("user_exercise").child("all_exercise").observeSingleEvent(of: .value) { (countSnapShot) in
                    let countExercise = countSnapShot.childrenCount
                     
                    for cnt in 0..<countExercise {
                        self.ref.child("user_exercise").child("all_exercise/\(cnt)").observeSingleEvent(of: .value) { (detailSnapShot) in
                            var oneExerciseDic:Dictionary<String, Any> = [:]
                            
                            let singleVal = detailSnapShot.value as? NSDictionary
                            let exerciseUid = singleVal?.value(forKeyPath: "uid") as? String ?? ""
                            var userTotalScoreInt:Int?
                            var userTotalCalBurn:Int?
                            ////print("exerciseUid : \(exerciseUid) and userKey : \(userKey)")
                            if exerciseUid == userKey{
                                //print("append!!!")
                                // oneExerciseDic = singleVal as! Dictionary<String, Any>
                                oneExerciseDic["nick_name"] = "\(String(describing: user_nick_name))"
                                
                                // 해당 구간에서 user key 기준으로 칼로리, 점수 합산하기
                                let exerciseResultTotalSocore = singleVal?.value(forKeyPath: "result_total_score") as? String ?? ""
                                let exerciseResultTotalCalBurn = String(format: "%.1f", singleVal?.value(forKeyPath: "total_cal_burn") as? String ?? "")
                                
                                guard exerciseResultTotalSocore != "" else {
                                    return
                                }
                                
                                guard exerciseResultTotalCalBurn != "" else {
                                    return
                                }
                                
                                userTotalScoreInt = Int(exerciseResultTotalSocore)!
                                userTotalCalBurn = Int(exerciseResultTotalCalBurn) ?? 0
                                
                                oneExerciseDic["result_total_score"] = "\(String(describing: userTotalScoreInt))"
                                oneExerciseDic["total_cal_burn"] = "\(String(describing: userTotalCalBurn))"
                                
                                // 총합산.. String -> Int 전환...
                                
                                // 가능하면 총 시간.. 이거는 조금 복잡할거 같음..
                                
                                // 다음단계는 랭킹 순위 연산..
                                
                                // list dictionary 내부에 append 대신 key 값을 체크 하는 과정 추가하기..
                                
                                if self.list.count == 0 {
                                    self.list.append((oneExerciseDic as NSDictionary) as! Dictionary<String, AnyObject>)
                                }else {
                                    for var exchangeList in self.list {
                                        
                                        if user_nick_name == exchangeList["nick_name"] as! String {
                                            guard var checkList = exchangeList["result_total_score"] else {
                                                return
                                            }
                                            
                                            var plusScoreInt:Int = 0
                                            
                                            plusScoreInt = plusScoreInt + userTotalScoreInt!
                                            //exchangeList["result_total_score"]
                                            exchangeList["result_total_score"] = String(plusScoreInt) as AnyObject
                                        }else {
                                            self.list.append((oneExerciseDic as NSDictionary) as! Dictionary<String, AnyObject>)
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.tableViewRangKing.reloadData() //Main
                                }
                                ////print("list append : \(self.list)")
                                //self.list[Int(cnt)]["nick_name"] = user_nick_name as? String
                            }
                            ////print("singleVal \(String(describing: singleVal))")
                        }
                        
                    }
                    
                    
                }

            }
            
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(" tableView :  \(self.list.count)")
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.list[indexPath.row]
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "scoreCell")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as! RangKingCell
        var allExerciseText = ""
        
        allExerciseText = " \(String(describing: obj["nick_name"] as? String)) | \(obj["total_cal_burn"] as! String) | \(obj["result_total_score"] as! String)"
        
        cell.textLabel?.text = allExerciseText
        
        //cell.name? = obj?["nick_name"] as! String
        //cell.cal? = obj?["total_cal_burn"] as! String
        //cell.score? = obj?["result_total_score"] as! String
    
        return cell
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

