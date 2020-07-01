//
//  CheckViewController.swift
//  TajikKeyboard
//
//  Created by Aminjoni Abdullozoda on 4/25/19.
//  Copyright © 2019 Aminjoni Abdullozoda. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollViewData : UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    let padding : CGFloat = 15
    
    var xpos : CGFloat = 0.0
    
    let images = [UIImage(named: "1tutor"),UIImage(named: "2tutor"), UIImage(named: "3tutor"),UIImage(named: "4tutor")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupContentSizeContainer()
        
        scrollViewData.delegate = self
    }
    
    //setup Container
    private func setupContentSizeContainer () {
        
        self.scrollViewData.contentSize = CGSize(width: self.view.frame.width * CGFloat(images.count), height: 0 )
        
        for i in 0..<images.count {
            
            let imageView = UIImageView()
                imageView.image = images[i]
                imageView.contentMode = .scaleAspectFit
            
            let xPos = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: view.frame.width, height: self.scrollViewData.frame.height - self.scrollViewData.frame.height / 4 )
            self.scrollViewData.addSubview(imageView)
        }
        
    
    }
    
    
    @IBAction func nextBtnDidTaped(_ sender: Any) {
        
        let pageIndex = round(scrollViewData.contentOffset.x/view.frame.width)
        
        if pageIndex == 2.0 {
            self.nextButton.setTitle("Открыть настройку", for: .normal)
        }
        else if pageIndex == 3.0 {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl)  {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
                else  {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
            
            return
        } else  {
            self.nextButton.setTitle("Следующий", for: .normal)
        }
        
        scrollViewData.setContentOffset(CGPoint(x: self.view.frame.width * (pageIndex + 1), y: 0), animated: true)
        
    }
    
}

extension TutorialViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/(self.view.frame.width))
        pageControll.currentPage = Int(pageIndex)
        
        if pageIndex == 3.0 {
            self.nextButton.setTitle("Открыть настройку", for: .normal)
        } else  {
            self.nextButton.setTitle("Следующий", for: .normal)
        }
    }
}
