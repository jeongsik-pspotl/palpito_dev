//
//  RangkingSampleController.swift
//  Palpito
//
//  Created by 김정식 on 2021/05/22.
//  Copyright © 2021 김정식. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift


class TableHeader: UITableViewHeaderFooterView {
    static let identifier = "TableHeader"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "RangkingMetal")
        return imageView
    }()
    
    private let subtitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "RangkingNaming")
//        imageView.backgroundColor = .white
        
        
        return imageView
    }()
    
    private let cellcoluemView: UIView = {
        
        let cellView = UIView()
        cellView.backgroundColor = .white
        
        if Locale.current.languageCode == "ko" {
            let awardCnt = UIImageView()
            awardCnt.contentMode = .scaleAspectFit
            awardCnt.image = UIImage(named: "RangkingCellAward")
            awardCnt.frame = CGRect(x: 20, y: 10, width: 25, height: 20)
            
            let cellID = UIImageView()
            cellID.contentMode = .scaleAspectFit
            cellID.image = UIImage(named: "RangkingCellid")
            cellID.frame = CGRect(x: 170, y: 10, width: 40, height: 20)
            
            let cellScore = UIImageView()
            cellScore.contentMode = .scaleAspectFit
            cellScore.image = UIImage(named: "RangkingCellScore")
            cellScore.frame = CGRect(x: 310, y: 10, width: 40, height: 20)
            
            cellView.addSubview(awardCnt)
            cellView.addSubview(cellID)
            cellView.addSubview(cellScore)
        }else {
            let awardCnt = UILabel()
            awardCnt.contentMode = .scaleAspectFit
            awardCnt.text = "Ranking" //UIImage(named: "RangkingCellAward")
            awardCnt.frame = CGRect(x: 20, y: 10, width: 70, height: 20)
            
            let cellID = UILabel()
            cellID.contentMode = .scaleAspectFit
            cellID.text = "ID"
            cellID.frame = CGRect(x: 170, y: 10, width: 50, height: 20)
            
            let cellScore = UILabel()
            cellScore.contentMode = .scaleAspectFit
            cellScore.text = "Score"  // UIImage(named: "RangkingCellScore")
            cellScore.frame = CGRect(x: 310, y: 10, width: 50, height: 20)
            
            cellView.addSubview(awardCnt)
            cellView.addSubview(cellID)
            cellView.addSubview(cellScore)
        }
        
        
        
        return cellView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imageView)
        contentView.addSubview(subtitleView)
        contentView.addSubview(cellcoluemView)
        contentView.backgroundColor = #colorLiteral(red: 0.9561954141, green: 0.4134745598, blue: 0.1289491951, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //label.sizeToFit()
//        label.frame = CGRect(x: 0, y: contentView.frame.size.height-10-label.frame.size.height, width: contentView.frame.size.width, height: label.frame.size.height)
        imageView.sizeToFit()
        subtitleView.sizeToFit()
        imageView.frame = CGRect(x: 130, y: 20, width: 40, height: 40)
        subtitleView.frame = CGRect(x: 170, y: 30, width: 70, height: 30)
        cellcoluemView.frame = CGRect(x: 0, y: 70, width: contentView.bounds.size.width, height: 40)
    }
    
}

class TableCell: UITableViewCell {
    
    static let identifier = "TableCell"
    
    private let cal: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        
        return label
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        
        return label
    }()
    
    private let score: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        
        return label
    }()
    
    func setCal(text :String){
        cal.text = text
        
    }
    
    func setName(text :String){
        name.text = text
    }
    
    func setScore(text :String) {
        score.text = text
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cal)
        contentView.addSubview(name)
        contentView.addSubview(score)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cal.sizeToFit()
        name.sizeToFit()
        score.sizeToFit()
        cal.frame = CGRect(x: 20, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
        name.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
        score.frame = CGRect(x: -30, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
    }
}

class TableFooter: UITableViewHeaderFooterView {
    
}

class RangkingSampleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var list = [Dictionary<String, AnyObject>]()
    var user_list_dic = [Dictionary<String, AnyObject>]()
    //var user_total_score = [Dictionary<String, AnyObject>]()
    //var total_user_rangking_list = [Dictionary<String, AnyObject>]()
    
    var db: Firestore!
    
    var startPoint = 0
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.register(TableHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.register(TableCell.self, forCellReuseIdentifier: "scoreCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        view.addSubview(tableView)
        self.getAllUser()
        
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.list[indexPath.row]
        
        let recell = tableView.dequeueReusableCell(withIdentifier: "scoreCell") as! TableCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath)
//        var allExerciseText = ""
//
//        allExerciseText = " \(indexPath.row + 1) 이름 :  \(obj["nick_name"] as! String) 점수 : \(obj["result_total_score"] as! Int)"
        
        recell.setCal(text: "\(indexPath.row + 1)")
        recell.setName(text: "\(obj["nick_name"] as! String)")
        recell.setScore(text: "\(obj["result_total_score"] as! Int)")
    
        return recell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func getAllUser() {
        // print("getAllUser start ")
        db.collection("user_info").getDocuments { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
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
                        //print("Error getting documents: \(err)")
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
                            self.tableView.reloadData() //Main
                            // self.resultScoreData()
                        }
                    }
                }
        }
        
    }
    
    func sum(numbers: [Int]) -> Int {
      // 1
      return numbers.reduce(0, +)
      // 2
      
    }
}
