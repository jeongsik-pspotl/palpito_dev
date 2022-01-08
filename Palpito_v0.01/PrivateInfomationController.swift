//
//  PrivateInfomationController.swift
//  Palpito
//
//  Created by 김정식 on 2020/07/25.
//  Copyright © 2020 김정식. All rights reserved.
//


import UIKit
import WebKit

class PrivateInfomationCotroller: UIViewController {
    
    @IBOutlet weak var privateInfomationView: UIView!
    @IBOutlet weak var wvMain: WKWebView!
    
    var languageCode = Locale.current.languageCode
    
    func goWeb(postfix: String) -> () {
        
        if languageCode == "ko" {
            let url = URL(string: "https://app.palpito.co.kr/")
            let request = URLRequest(url: url!)
            wvMain.load(request)
        } else {
            let url = URL(string: "https://blog.naver.com/palpito0613/222465762337")
            let request = URLRequest(url: url!)
            wvMain.load(request)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = view.bounds.width / privateInfomationView.bounds.width
        
        privateInfomationView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // Do any additional setup after loading the view.
        goWeb(postfix: "scale")
        
    }
    
    @IBAction func backWorkoutPageAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

//    @IBAction func btnScale(_ sender: UIButton) {
//        goWeb(postfix: "scale")
//    }
    
//    @IBAction func btnFreq(_ sender: UIButton) {
//        goWeb(postfix: "freq")
//    }
}
