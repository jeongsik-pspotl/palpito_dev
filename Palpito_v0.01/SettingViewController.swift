//
//  SettingViewController.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/23.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit
import FirebaseAuth
import WatchConnectivity

@available(iOS 13.4, *)
class SettingViewController: UITableViewController, WCSessionDelegate {
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
    
    //var list = [MovieVO]()
    var dataset = [
        ("계정 정보"),("개인 정보 공개 범위"),("로그아웃")
    ]
    
    var datasetEng = [
        ("Account Information"),("Scope of disclosure of personal information"),("Log out")
    ]
    
    var languageCode = Locale.current.languageCode
    
    weak var session:WCSession?
    
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
    
    // datasetEng
    
    lazy var listEng: [MovieVO] = {
        var datalistEng = [MovieVO]()
        
        for (titleEng) in self.datasetEng {
            let mvoEng = MovieVO()
            mvoEng.title = titleEng
            datalistEng.append(mvoEng)
        }
        
        return datalistEng
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            
            //print("session activate")
            if session!.isPaired != true {
                //print("Apple Watch is not paired")
            }else {
                //print("Apple Watch is paired")
                
            }
        } else {
            //print("session error")
        }
        
        
        //self.title = "Palpito"
        //self.navigationController?.navigationBar.barTintColor = .white
                
        //self.myTableView.backgroundColor = UIColor.init(white: 0.0, alpha: 1.0)
        //self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        //        self.myTableView.contentInsetAdjustmentBehavior = .never
                
        //        cell.contentView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.02)
                
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        //self.myTableView.tableFooterView = UIView() //extra sepearor를 지움
        
        //let nibName = UINib(nibName: "ConfigCell", bundle: nil)
        //self.myTableView.register(nibName, forCellReuseIdentifier: "ConfigCell")

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("선택된 행은 \(indexPath.row) 번째 입니다.")
        if languageCode == "ko" {
            let row = self.list[indexPath.row]
            
            if row.title == "로그아웃" {
                //print("로그아웃")
                // 팝업 창 준비 로그아웃 하시겠습니까?
                let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .destructive) { (alert) in
                    let firebaseAuth = Auth.auth()
                    
                    do {
                        try firebaseAuth.signOut()
                        // 로그인 화면 이동..
                        UserDefaults.standard.set("notSelected", forKey: "isAutoLoginCheck")
                        
                        if let validSession = self.session {
                            let data: [String: Any] = ["logincheck": "No" as Any]
                            UserDefaults.standard.set("No" , forKey: "logincheck")
                            validSession.transferUserInfo(data)
                            
                        }
                        
                        // self.dismiss(animated: true, completion: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewSb") as! ViewController
                        storyboard.modalPresentationStyle = .fullScreen
                        self.present(storyboard, animated: true, completion: nil)
                        self.view.removeFromSuperview()

                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                }
                // 예 하면 로그 아웃 하면서
                
                // 로그인 화면으로 이동
                
                let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler : nil)
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: false, completion: nil)
                
            }
            
            if row.title == "개인 정보 공개 범위" {
                //print("개인 정보 공개 범위")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "PrivateInfomationCotroller") as! PrivateInfomationCotroller
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
            }
            
            if row.title == "계정 정보" {
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "UserInfoSettingController") as! UserInfoSettingController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
            }
            
        } else {
            let row = self.listEng[indexPath.row]
            
            if row.title == "Log out" {
                //print("로그아웃")
                // 팝업 창 준비 로그아웃 하시겠습니까?
                let alert = UIAlertController(title: "Log out", message: "do you want to log out?", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .destructive) { (alert) in
                    let firebaseAuth = Auth.auth()
                    
                    do {
                        try firebaseAuth.signOut()
                        // 로그인 화면 이동..
                        UserDefaults.standard.set("notSelected", forKey: "isAutoLoginCheck")
                        
                        if let validSession = self.session {
                            let data: [String: Any] = ["logincheck": "No" as Any]
                            UserDefaults.standard.set("No" , forKey: "logincheck")
                            validSession.transferUserInfo(data)
                            
                        }
                        
                        // self.dismiss(animated: true, completion: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewSb") as! ViewController
                        storyboard.modalPresentationStyle = .fullScreen
                        self.present(storyboard, animated: true, completion: nil)
                        self.view.removeFromSuperview()

                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                }
                // 예 하면 로그 아웃 하면서
                
                // 로그인 화면으로 이동
                
                let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler : nil)
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: false, completion: nil)
                
            }
            
            if row.title == "Scope of disclosure of personal information" {
                //print("개인 정보 공개 범위")
                
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "PrivateInfomationCotroller") as! PrivateInfomationCotroller
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
            }
            
            if row.title == "Account Information" {
                let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "UserInfoSettingController") as! UserInfoSettingController
                storyboard.modalPresentationStyle = .fullScreen
                self.present(storyboard, animated: true, completion: nil)
            }
            
        }
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if languageCode == "ko" {
            return self.list.count
        }else {
            return self.listEng.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(" indexPath : \(indexPath) ")
        if languageCode == "ko" {
            let row = self.list[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
            cell.textLabel?.text = row.title
            
            return cell
        } else {
            let row = self.listEng[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
            cell.textLabel?.text = row.title
            
            return cell
        }
        
    }

}


