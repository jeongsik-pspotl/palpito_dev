//
//  RangKingViewController.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/31.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RankingViewController: UITableViewController {
    
    var list = [Dictionary<String, AnyObject>]()
    var user_list_dic = [Dictionary<String, AnyObject>]()
    var user_list = [String]()
    var user_total_score = [Dictionary<String, AnyObject>]()
    var total_user_rangking_list = [Dictionary<String, AnyObject>]()
    
    var db: Firestore!
    
    var startPoint = 0
    
    @IBOutlet var tableViewRangKing: UITableView!
    
    override func viewDidLoad() {
        db = Firestore.firestore()
        
        self.getAllUser()
        
        tableViewRangKing.delegate = self
        tableViewRangKing.dataSource = self
        
        
    }
    
    
    func getAllUser() {
        // print("getAllUser start ")
        db.collection("user_info").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //print("\(querySnapshot)")
                var oneExerciseDic:Dictionary<String, Any> = [:]
                
                for document in querySnapshot!.documents {
                    // uid, nick_name
                    // var querySnapshot = document.data().values
                    let querySnapshot = document.data()
                    oneExerciseDic["nick_name"] = querySnapshot["nick_name"]!
                    oneExerciseDic["uid"] = document.documentID
                    
                    self.user_list_dic.append((oneExerciseDic as NSDictionary) as! Dictionary<String, AnyObject>)
                    
                    //print(querySnapshot["nick_name"]!)
                    //print(document.documentID)
                    
                    //print("\(document.documentID) => \(document.data())")
                    
                }
                // 다음 단계 진행
                //print(" user_info end ")
                self.getTop100()
            }
        }
    }
    
    //user_key 중복제거를 해서 그 사용자를 뽑는 건지 
    func getTop100() {
        //print("getTop100 start ")
        
        for user in self.user_list_dic {
                // all_exercise to user_exercise
                db.collection("user_exercise").whereField("uid",isEqualTo: user["uid"] as! String).getDocuments { (querySnapshot, err) in
                    var score = [Int]()
                    var oneUserExerciseDic:Dictionary<String, Any> = [:]
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        for document in querySnapshot!.documents {
                            
                            let all_exerciseDocuemnt = document.data()
                            //print("\(document.documentID) => \(document.data())")
                            
                            //oneUserExerciseDic["nick_name"] = user["nick_name"]
                            score.append(all_exerciseDocuemnt["result_total_score"] as! Int)

                        }
                            
                        // 1 uid user_list_dic 리스트 for loop 문 조회
                        // 2 uid 기준으로 where 조회 쿼리
                        // 3 집계 쿼리 구현 시작
                            
                        //print(querySnapshot["nick_name"]!)
                        //print(document.documentID)
                        
                        // 다음 단계 진행
                        oneUserExerciseDic["nick_name"] = user["nick_name"]!
                        oneUserExerciseDic["result_total_score"] = self.sum(numbers: score) as Int
                        self.list.append((oneUserExerciseDic as NSDictionary) as! Dictionary<String, AnyObject>)
                        //print("all exercise end ... ")
                        self.list.sort { (score1, score2) -> Bool in
                            let result_score1 = score1["result_total_score"] as! Int
                            let result_score2 = score2["result_total_score"] as! Int
                            return result_score1 > result_score2
                        }

                        
                        DispatchQueue.main.async {
                            self.tableViewRangKing.reloadData() //Main
                            //self.resultScoreData()
                        }
                    }
                }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.list[indexPath.row]
        //print(obj)
        //let cell = UITableViewCell.init(style: .default, reuseIdentifier: "scoreCell")
        let recell = tableView.dequeueReusableCell(withIdentifier: "scoreCell") as! RangKingCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath)
//        var allExerciseText = ""
//
//        allExerciseText = " \(indexPath.row + 1) 이름 :  \(obj["nick_name"] as! String) 점수 : \(obj["result_total_score"] as! Int)"
        
        recell.cal.text = "\(indexPath.row + 1)"
        recell.name.text = "\(obj["nick_name"] as! String)"
        recell.score.text = "\(obj["result_total_score"] as! Int)"
    
        return recell
    }
    
    func sum(numbers: [Int]) -> Int {
      // 1
      return numbers.reduce(0, +)
      // 2
      
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

