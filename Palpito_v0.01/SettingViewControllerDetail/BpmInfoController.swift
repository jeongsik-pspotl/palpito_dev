//
//  BpmInfoController.swift
//  PalpitoExample
//
//  Created by Taesup Yoon on 2020. 3. 22..
//  Copyright © 2020년 Taesup Yoon. All rights reserved.
//

import UIKit

class BpmInfoController: UIViewController {
    
    @IBOutlet weak var titleCalendar: UILabel!
    
    @IBOutlet weak var btnMonthly: UIButton!
    @IBOutlet weak var btnDaily: UIButton!
    
    
    @IBOutlet weak var titleDate: UILabel!
    @IBOutlet weak var subTitleDate: UILabel!
    
    
    @IBOutlet weak var leftLabel1: UILabel!
    @IBOutlet weak var leftLabel2: UILabel!
    @IBOutlet weak var leftLabel3: UILabel!
    @IBOutlet weak var leftLabel4: UILabel!
    @IBOutlet weak var leftLabel5: UILabel!
    
    
    @IBOutlet weak var rightLabel1: UILabel!
    @IBOutlet weak var rightLabel2: UILabel!
    @IBOutlet weak var rightLabel3: UILabel!
    @IBOutlet weak var rightLabel4: UILabel!
    @IBOutlet weak var rightLabel5: UILabel!
    
    var rightData1 = "0" //bpm
    var rightData2 = "0" //kcal
    var rightData3 = "0" //km
    var rightData4_hour = "0" //time
    var rightData4_min = "0" //time
    var rightData5 = "0" //point
    
    let fontSize = CGFloat(14)
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateToday()
        
        btnMonthly.setTitleColor(.orange, for: .normal)
        btnMonthly.layer.cornerRadius = 10
        btnMonthly.layer.borderColor = UIColor.orange.cgColor
        btnMonthly.layer.borderWidth = 2.0
        
        btnDaily.setTitleColor(.orange, for: .normal)
        btnDaily.layer.cornerRadius = 10
        btnDaily.layer.borderColor = UIColor.orange.cgColor
        btnDaily.layer.borderWidth = 2.0
        
        leftLabel1.font = UIFont.systemFont(ofSize: fontSize)
        leftLabel2.font = UIFont.systemFont(ofSize: fontSize)
        leftLabel3.font = UIFont.systemFont(ofSize: fontSize)
        leftLabel4.font = UIFont.systemFont(ofSize: fontSize)
        leftLabel5.font = UIFont.systemFont(ofSize: fontSize)

        updateRightData(rightLabel1, value: rightData1, symbol: "bpm")
        updateRightData(rightLabel2, value: rightData2, symbol: "kcal")
        updateRightData(rightLabel3, value: rightData3, symbol: "km")
        updateRightTowData(rightLabel4, value1: rightData4_hour, value2: rightData4_min, symbol1: "시간", symbol2: "분")
        updateRightData(rightLabel5, value: rightData5, symbol: "점")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// event
extension BpmInfoController {
    func updateToday() {
//        let now = Date()
//
//        let date = DateFormatter()
//        date.locale = Locale(identifier: "ko_kr")
//        date.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
//        //date.timeZone = TimeZone(abbreviation: "NZST") // "2018-03-21 22:06:39"
//        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//        let kr = date.string(from: now)
        
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        date.dateFormat = "yyyy.MM.dd"
        subTitleDate.text = date.string(from: Date())
        
//        let time = date.date(from: "2017-06-05")
    }
    
    @IBAction func btnMonthlyClicked(_ sender: Any) {
        //print(1)
    }
    @IBAction func btnDailyClicked(_ sender: Any) {
        //print(2)
    }
}


// data handle
extension BpmInfoController {
    
    func updateRightData(_ label: UILabel, value: String, symbol: String) {
        let colorString = NSMutableAttributedString(string: "\(value)\(symbol)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        colorString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: NSRange(location:0, length: value.characters.count))
        label.attributedText = colorString
    }
    
    func updateRightTowData(_ label: UILabel, value1: String, value2: String, symbol1: String, symbol2: String) {
        let colorString = NSMutableAttributedString(string: "\(value1)\(symbol1)\(value2)\(symbol2)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        colorString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: NSRange(location:0, length: value1.characters.count))
        colorString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: NSRange(location:value1.characters.count + symbol1.characters.count, length: value2.characters.count))
        label.attributedText = colorString
    }
}
