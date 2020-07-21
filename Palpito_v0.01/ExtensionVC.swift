//
//  ExtensionVC.swift
//  Palpito
//
//  Created by 김정식 on 2020/07/20.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit

class ExtensionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension UIViewController {

    class func displaySpinner(onView: UIView) -> UIView {

        let spinnerView = UIView.init(frame: onView.bounds)

        

        spinnerView.backgroundColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center

        DispatchQueue.main.async {

            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)

        }
        
        return spinnerView

    }

    

    class func removeSpinner(spinner : UIView) {

        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }

    }

}

