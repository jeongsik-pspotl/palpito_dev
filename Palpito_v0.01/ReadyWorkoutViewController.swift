//
//  ReadyWorkoutViewController.swift
//  Palpito
//
//  Created by 김정식 on 28/02/2019.
//  Copyright © 2019 김정식. All rights reserved.
//

import UIKit
import WatchConnectivity

class ReadyWorkoutViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var readyImageView: UIImageView!
    
    var readyImages: [UIImage] = []
    weak var wcSession:WCSession?
    
    var stageLevel = ""
    
    deinit {
        //print("deinit ReadyWorkout.... ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()

            ////print("session activate")
            
        } else {
            //print("session error")
            
        }
        
        readyImages = createImageArray(total: 4, imagePrefix: "count")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animate(imageView: readyImageView, images: readyImages)
//        sleep(UInt32(4))
//        //print("타이밍 체크.. 준비")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // showGetWorkout
            self.performSegue(withIdentifier: "showGetWorkout", sender: self)
            self.view.removeFromSuperview()
            //let storyboard = UIStoryboard(name: "StartApp", bundle: nil).instantiateViewController(withIdentifier: "WorkoutViewController") as! WorkoutViewController
//            storyboard.modalPresentationStyle = .fullScreen
            
            //self.navigationController!.pushViewController(storyboard, animated: true)
            //self.present(storyboard, animated: true, completion: nil)
            //self.readyImages.removeAll()
            //self.readyImageView.removeFromSuperview()
            //self.readyImageView = nil
        }
        
//        //print("타이밍 체크.. 외부")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            
            ////print("session activate")
        } else {
            //print("session error")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //wcSession = nil
        ////print("load did viewWillDisappear??")
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //wcSession = nil
        ////print("load did viewDidDisappear??")
    }
    
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        
        var imageArray: [UIImage] = []
        
        for imageCount in 0..<total {
            let imageName = "\(imagePrefix)-\(imageCount)"
            let image = UIImage(named: imageName)!
            
            imageArray.append(image)
        }
        
        return imageArray
    }

    func animate(imageView: UIImageView, images:[UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 3.0
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
//        //print("타이밍 체크.. 내부")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        ////print("activationState : \(activationState)")
        ////print("session : \(session)")
        //print("error \(error as Any)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        ////print("sessionDidBecomeInactive : \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        ////print("sessionDidDeactivate : \(session)")
    }

}
