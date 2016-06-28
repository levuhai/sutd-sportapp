//
//  TourGuiderController.swift
//  Sport
//
//  Created by Tien on 6/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class TourGuiderController: UIViewController {

    @IBOutlet weak var gotItButton: UIButton!
    var pageViewController: UIPageViewController!
    
    let pageTitles = ["Hello", "Welcome to Sport", "Final screen"]
    let pageImages = ["bgImage", "bgImage", "bgImage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        pageViewController = storyboard.instantiateViewControllerWithIdentifier("TutorialPageContainer") as! UIPageViewController
        pageViewController.dataSource = self
        
        let firstController = contentViewControllerAtIndex(0)!
        pageViewController.setViewControllers([firstController], direction: .Forward, animated: false, completion: nil)
        
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 78)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
        gotItButton.layer.borderColor = UIColor.greenColor().CGColor
        gotItButton.layer.borderWidth = 1.0
        gotItButton.layer.cornerRadius = 2.0
    }

    
    @IBAction func gotItButtonDidClick(sender: UIButton) {
        let finished = true
        AppUserDefaults.saveTutorialStatus(finished)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialScreen = storyboard.instantiateViewControllerWithIdentifier("InitialViewController")
        navigationController?.setViewControllers([initialScreen], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func contentViewControllerAtIndex(index: Int) -> UIViewController? {
        if (index < 0 || index >= pageTitles.count) {
            return nil
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentController = storyboard.instantiateViewControllerWithIdentifier("PageContentController") as! TourGuideContentController
        contentController.pageIndex = index
        contentController.pageTitle = pageTitles[index]
        contentController.guideImageName =  pageImages[index]
        return contentController
    }
}

extension TourGuiderController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let contentController = viewController as! TourGuideContentController
        let pageIndex = contentController.pageIndex
        
        // Last page
        if (pageIndex == pageTitles.count - 1) {
            return nil
        }
        
        return contentViewControllerAtIndex(pageIndex + 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let contentController = viewController as! TourGuideContentController
        let pageIndex = contentController.pageIndex
        
        // Last page
        if (pageIndex == 0) {
            return nil
        }
        return contentViewControllerAtIndex(pageIndex - 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}