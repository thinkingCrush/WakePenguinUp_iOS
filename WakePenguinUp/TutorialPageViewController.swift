//
//  ViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 05/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//
import Foundation
import UIKit
import ImageSlideshow

class TutorialPageViewController: BaseViewController{
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    var pageControl = UIPageControl()
    
    var helpType = 0
    
    var localSource : [BundleImageSource] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
        
        localSource = [BundleImageSource(imageString: "page_help_1"), BundleImageSource(imageString: "page_help_2")]
//        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.circular = false
//        slideshow.contentScaleMode = UIViewContentMode.scaleToFill
        slideshow.contentScaleMode = .scaleAspectFit
        slideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(localSource)
        
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TutorialPageViewController.didTap))
//        slideshow.addGestureRecognizer(recognizer)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.shouldSupportAllOrientation = false
    }
//    @objc func didTap() {
//        let fullScreenController = slideshow.presentFullScreenController(from: self)
//        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
//        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
//    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: 60 , height: 50))
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.numberOfPages = localSource.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.white
        
        self.pageControl.currentPageIndicatorTintColor = UIColor.colorFromHex(65585)
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        
        self.pageControl.isUserInteractionEnabled = false
        
        self.view.addSubview(pageControl)
    }
}

extension TutorialPageViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        if page == 1 {
            let nextButton = UIButton(frame: CGRect(x: view.frame.width-100, y: view.frame.height-100, width: 70, height: 70))
            nextButton.setTitle("skip", for: .normal)
            nextButton.backgroundColor = UIColor.colorFromHex(65585)
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.contentVerticalAlignment = .center
            nextButton.layer.cornerRadius = 35
            nextButton.tag = 100
            nextButton.addTarget(self, action: #selector(moveToMain), for: .touchUpInside)
            
            self.view.addSubview(nextButton)
            
            nextButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3, animations: {
                nextButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (success) in
                
            }
            
        }else {
            
            if let viewWithTag = self.view.viewWithTag(100) {
                UIView.animate(withDuration: 0.3, animations: {
                    viewWithTag.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { (success) in
                    viewWithTag.removeFromSuperview()
                }
            }else {
                print("No NextButton")
            }
        }
    }
    
    @objc func moveToMain() {
        let userDefault = UserDefaults.standard
        userDefault.setValue(true, forKey: "isStartApp")
        userDefault.synchronize()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainNaviVC") as? UINavigationController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
