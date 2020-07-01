//
//  ProfileViewController.swift
//  TajikKeyboard
//
//  Created by Aminjoni Abdullozoda on 4/25/19.
//  Copyright © 2019 Aminjoni Abdullozoda. All rights reserved.




import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //about view - shadow, layer
    }
    
    @IBAction func aminjoni(_ sender: Any) {
        openURL(url: "https://www.linkedin.com/in/aminjoni-abdullozoda-28736a10a/")
    }
    
   
    @IBAction func gani(_ sender: Any) {
        openURL(url: "https://www.linkedin.com/in/gani-rahmon-a8b317184/")
    }
    
    private func openURL (url : String) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func CrytoShare(_ sender: UIButton) {
        
        var crytoAdress = ""
        switch sender.tag {
        case 0:
            crytoAdress = "BTC Wallet Adress : 14BKegWwoppRBUcFFRZuLEpoAxnu5xkYM6"
            break
        case 1:
            crytoAdress = "ETH Wallet Adress : 0x7772DdB20d3069BA567229730eb94074dBB0f01e"
            break
        case 2:
            crytoAdress = "LTC Wallet Adress : 14BKegWwoppRBUcFFRZuLEpoAxnu5xkYM6"
            break
        default:
            crytoAdress = "BTC Wallet Adress : LN6e952YLgaswNAfrP3PbxfRyzteKpSC15"
            break
        }
        
        //share action
     
        let shareAction = UIActivityViewController(activityItems: [crytoAdress], applicationActivities: nil)
        self.present(shareAction, animated: true, completion: nil)
        
        if let popOver = shareAction.popoverPresentationController {
            popOver.sourceView = self.view
        }
        
    }
}
