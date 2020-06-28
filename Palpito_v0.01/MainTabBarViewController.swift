//
//  MainTabBarViewController.swift
//  Palpito
//
//  Created by 김정식 on 13/02/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    var freshLanush = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        // 내상태 화면으로 이동
        self.selectedIndex = 0
//        //print("selectedIndex MainTabBarViewController ..")
//        //print(self.selectedIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if freshLanush == true {
            freshLanush = false
            self.selectedIndex = 0
        }
        self.modalPresentationStyle = .fullScreen
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
