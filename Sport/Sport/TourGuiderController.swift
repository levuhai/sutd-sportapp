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
        
        self.navigationController?.isNavigationBarHidden = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        pageViewController = storyboard.instantiateViewController(withIdentifier: "TutorialPageContainer") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstController = contentViewControllerAtIndex(0)!
        pageViewController.setViewControllers([firstController], direction: .forward, animated: false, completion: nil)
        
        pageViewController.view.frame = UIScreen.main.bounds
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        pageControl.numberOfPages = pageTitles.count;
        view.bringSubview(toFront: pageControl)
    }
    
    func gotItButtonDidClick() {
        let finished = true
        AppUserDefaults.saveTutorialStatus(finished)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialScreen = storyboard.instantiateViewController(withIdentifier: "InitialViewController")
        navigationController?.setViewControllers([initialScreen], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func contentViewControllerAtIndex(_ index: Int) -> TourGuideContentController? {
        if (index < 0 || index >= pageTitles.count) {
            return nil
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentController = storyboard.instantiateViewController(withIdentifier: "PageContentController") as! TourGuideContentController
        contentController.pageIndex = index
        contentController.pageTitle = pageTitles[index]
        contentController.guideImageName =  pageImages[index]
        return contentController
    }
}

extension TourGuiderController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let contentController = viewController as! TourGuideContentController
        let pageIndex = contentController.pageIndex
        
        // After last page
        if (pageIndex == pageTitles.count - 1) {
            return nil
        }
        
        let controller = contentViewControllerAtIndex(pageIndex + 1)
        // Last page
        if (controller?.pageIndex == pageTitles.count - 1) {
            controller?.enableFinishButtonWithAction({ 
                self.gotItButtonDidClick()
            })
        }
        
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let contentController = pendingViewControllers[0] as! TourGuideContentController
        pageControl.currentPage = contentController.pageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            let contentController = previousViewControllers[0] as! TourGuideContentController
            pageControl.currentPage = contentController.pageIndex
        }
    }
}
