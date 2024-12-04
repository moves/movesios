//
//  RecordPopupViewController.swift
// //
//
//  Created by Wasiq Tayyab on 06/08/2024.
//

import UIKit

class RecordPopupViewController: UIViewController {
    
    @IBOutlet weak var lblShop: UILabel!
    @IBOutlet weak var btnPostProduct: UIButton!
    @IBOutlet weak var postProductView: CustomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func livePostButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            // go live
        }else{
            // post video
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc1 = storyboard.instantiateViewController(withIdentifier: "actionMediaViewController") as! actionMediaViewController
            let nav = UINavigationController(rootViewController: vc1)
            nav.isNavigationBarHidden =  true
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func showAlert(alertText : String, alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //Add more actions as you see fit
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
