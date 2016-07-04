//
//  TourGuiderController.swift
//  Sport
//
//  Created by Tien on 6/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class TourGuiderController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    var pageViewController: UIPageViewController!
    
    let pageTitles = ["Hello", "Welcome to Sport", "Final screen"]
    let pageImages = ["city_1", "city_2", "city_3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        pageViewController = storyboard.instantiateViewControllerWithIdentifier("TutorialPageContainer") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstController = contentViewControllerAtIndex(0)!
        pageViewController.setViewControllers([firstController], direction: .Forward, animated: false, completion: nil)
        
        pageViewController.view.frame = UIScreen.mainScreen().bounds
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        pageControl.numberOfPages = pageTitles.count;
        view.bringSubviewToFront(pageControl)
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
}

extension TourGuiderController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let contentController = pendingViewControllers[0] as! TourGuideContentController
        pageControl.currentPage = contentController.pageIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            let contentController = previousViewControllers[0] as! TourGuideContentController
            pageControl.currentPage = contentController.pageIndex
        }
    }
}