//
//  SettingViewController.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/23.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Palpito"
        self.navigationController?.navigationBar.barTintColor = .white
                
        self.myTableView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.02)
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        //        self.myTableView.contentInsetAdjustmentBehavior = .never
                
        //        cell.contentView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.02)
                
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.tableFooterView = UIView() //extra sepearor를 지움
        
        let nibName = UINib(nibName: "ConfigCell", bundle: nil)
        self.myTableView.register(nibName, forCellReuseIdentifier: "ConfigCell")

        // Do any additional setup after loading the view.
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

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = BpmInfoController(nibName: "BpmInfoController", bundle: nil)
//        self.navigationController!.pushViewController(vc, animated: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(" indexPath : \(indexPath) ")
        if (indexPath.row < 11) {
            var cell : ConfigCell!
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ConfigCell
            
            if cell == nil {
                cell = ConfigCell(style: .default, reuseIdentifier: cellIdentifier)
            }
            
            cell.title.text = rowTitles[indexPath.row]
            
            updateIconHidden(cell, indexPath: indexPath)
            updateSepartorHidden(cell, indexPath: indexPath)
            
            return cell
        } else {
            let cell = UITableViewCell()
            updateSepartorHidden(cell, indexPath: indexPath)
            
            let title = UILabel()
            let subTitle = UILabel()
            let divider = UIView()
            
            title.frame = CGRect(x: 10, y: 5, width: 100, height: 15)
            title.font = UIFont.systemFont(ofSize: 10.0)
            title.text = "from"
            title.textColor = .lightGray
            
            subTitle.frame = CGRect(x: 10, y: 20, width: 100, height: 15)
            subTitle.font = UIFont.systemFont(ofSize: 12.0)
            subTitle.text = "Palpito"
            
            
            divider.frame = CGRect(x: 0, y: cell.frame.height - 1, width: UIScreen.main.bounds.width, height: 1)
            divider.backgroundColor = UIColor.init(red: 0.98, green:  0.98, blue:  0.98, alpha: 1.0)
            
            
            
            cell.contentView.addSubview(title)
            cell.contentView.addSubview(subTitle)
            cell.contentView.addSubview(divider)
            cell.contentView.backgroundColor = UIColor.init(red: 0.98, green:  0.98, blue:  0.98, alpha: 1.0)
            
            
            return cell
        }
    }
    
    
}

extension SettingViewController {
    func updateIconHidden(_ cell: ConfigCell, indexPath: IndexPath) {
        if(indexPath.row <= 7) {
            cell.icon.image = UIImage(named: rowIcons[indexPath.row])
            cell.icon.isHidden = false
            cell.icon.widthAnchor.constraint(equalToConstant: CGFloat(10)).isActive = true //title move by autolayout
        } else {
            cell.icon.isHidden = true
            cell.icon.widthAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true //title move by autolayout
        }
    }
    
    func updateSepartorHidden(_ cell: UITableViewCell, indexPath: IndexPath) {
        if(indexPath.row == 7) {
            cell.separatorInset = .zero
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
    }
}
