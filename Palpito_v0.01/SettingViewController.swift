//
//  SettingViewController.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/23.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    //var list = [MovieVO]()
    var dataset = [
        ("계정 정보"),("개인 정보 공개 범위"),("보안"),("도움말"),("로그아웃")
    ]
    
    @IBOutlet weak var myTableView: UITableView!
    let username = "pspotl"
    let rowTitles: [String] = [
        "미정",
        "계정 정보",
        "로그아웃",
        "개인 정보 공개 범위",
        "보안",
        "도움말",
        "알림 미정",
        "미정",
        "계정",
        "미정",
        "미정"
    ]
    let rowIcons: [String] = [
        "icon",
        "alarm",
        "icon",
        "alarm",
        "icon",
        "alarm",
        "icon",
        "alarm"
    ]
    let cellIdentifier = "ConfigCell"
    
    lazy var list: [MovieVO] = {
        var datalist = [MovieVO]()
        
        for (title) in self.dataset {
            let mvo = MovieVO()
            mvo.title = title
            datalist.append(mvo)
        }
        return datalist
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Palpito"
        self.navigationController?.navigationBar.barTintColor = .white
                
        self.myTableView.backgroundColor = UIColor.init(white: 1.0, alpha: 1.0)
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        //        self.myTableView.contentInsetAdjustmentBehavior = .never
                
        //        cell.contentView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.02)
                
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        //self.myTableView.tableFooterView = UIView() //extra sepearor를 지움
        
        //let nibName = UINib(nibName: "ConfigCell", bundle: nil)
        //self.myTableView.register(nibName, forCellReuseIdentifier: "ConfigCell")

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택된 행은 \(indexPath.row) 번째 입니다.")
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(" indexPath : \(indexPath) ")
        let row = self.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
        cell.textLabel?.text = row.title
        
        return cell
    }

}


