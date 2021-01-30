//
//  GaryPortalSwipeController.swift
//  AlMurray
//
//  Created by Tom Knighton on 12/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

///Data source for GaryPortalSwipeController view
@objc
public protocol GPSwipeControllerDataSource {
    
    ///Returns the array of view controllers for the `GaryPortalSwipeController`
    func viewControllerData() -> [UIViewController]
    
    ///Sets and returns the index of the initial page from `viewControllerData()`
    @objc
    optional func indexOfStartingPage() -> Int // Defaults is 0
    
    ///Sets and returns the titles for the pages in `viewControllerData()`
    @objc
    optional func titlesForPages() -> [String]
    
    ///Sets and returns the navigation bar for a page from `viewControllerData()`
    @objc
    optional func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar
    
    ///Disables swiping for the left button for a specified page
    @objc
    optional func disableSwipingForLeftButtonAtPageIndex(_ index: Int) -> Bool
    
    ///Disables swiping for the right button for a specified page
    @objc
    optional func disableSwipingForRightButtonAtPageIndex(_ index: Int) -> Bool
    
    ///Called when the left button is pressed on a page
    @objc
    optional func clickedLeftButtonFromPageIndex(_ index: Int)
    
    ///Called when the right button is pressed on a page
    @objc
    optional func clickedRightButtonFromPageIndex(_ index: Int)
    
    ///Called when the current page index is changed
    @objc
    optional func changedToPageIndex(_ index: Int)
}

open class GaryPortalSwipeController: UIViewController {

    public struct Constants {
        
        public static var Orientation: UIInterfaceOrientation {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.portrait
        }
        public static var ScreenWidth: CGFloat {
            if Orientation.isPortrait {
                return UIScreen.main.bounds.width
            } else {
                return UIScreen.main.bounds.height
            }
        }
        public static var ScreenHeight: CGFloat {
            if Orientation.isPortrait {
                return UIScreen.main.bounds.height
            } else {
                return UIScreen.main.bounds.width
            }
        }
        public static var StatusBarHeight: CGFloat {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        public static var ScreenHeightWithoutStatusBar: CGFloat {
            if Orientation.isPortrait {
                return UIScreen.main.bounds.height - StatusBarHeight
            } else {
                return UIScreen.main.bounds.width - StatusBarHeight
            }
        }
        public static let navigationBarHeight: CGFloat = 44
        public static let lightGrayColor = UIColor(red: 248, green: 248, blue: 248, alpha: 1)
    }

    public var stackNavBars = [UINavigationBar]()
    public var stackVC: [UIViewController]!
    public var stackPageVC: [UIViewController]!
    public var stackStartLocation: Int!

    public var bottomNavigationHeight: CGFloat = 44
    open var pageViewController: UIPageViewController!
    public var titleButton: UIButton?
    open var currentStackVC: UIViewController!
    public var currentVCIndex: Int {
        return stackPageVC.firstIndex(of: currentStackVC)!
    }
    
    open weak var datasource: GPSwipeControllerDataSource?

    public var navigationBarShouldBeOnBottom = false
    public var navigationBarShouldNotExist = false
    public var cancelStandardButtonEvents = false

    public init() {
        super.init(nibName: nil, bundle: nil)
        
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }

    private func setupDefaultNavigationBars(_ pageTitles: [String]) {
        guard !navigationBarShouldNotExist else { return }

        var navBars = [UINavigationBar]()
        pageTitles.forEach { title in
            let navigationBarSize = CGSize(width: Constants.ScreenWidth, height: Constants.navigationBarHeight)
            let navigationBar = UINavigationBar(frame: CGRect(origin: CGPoint.zero, size: navigationBarSize))
            navigationBar.barStyle = .default
            navigationBar.barTintColor = Constants.lightGrayColor

            let navigationItem = UINavigationItem(title: title)
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil

            navigationBar.pushItem(navigationItem, animated: false)
            navBars.append(navigationBar)
        }
        stackNavBars = navBars
    }

    private func setupNavigationBar() {
        
        guard stackNavBars.isEmpty else { return }
        guard !navigationBarShouldNotExist else { return }

        if datasource?.navigationBarDataForPageIndex?(0) == nil {
            if let titles = datasource?.titlesForPages?() {
                setupDefaultNavigationBars(titles)
            }
            return
        }

        for index in 0..<stackVC.count {
            let navigationBar = datasource?.navigationBarDataForPageIndex?(index)

            if let navbar = navigationBar {
                if navigationBarShouldBeOnBottom {
                    navbar.frame = CGRect(x: 0, y: Constants.ScreenHeightWithoutStatusBar - Constants.navigationBarHeight, width: Constants.ScreenWidth, height: Constants.navigationBarHeight)
                } else {
                    navbar.frame = CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: Constants.navigationBarHeight)
                }
                
                if let items = navbar.items, !cancelStandardButtonEvents {
                    items.forEach { item in
                        if let leftButton = item.leftBarButtonItem {
                            leftButton.target = self
                            leftButton.action = #selector(leftButtonAction)
                        }
                        if let rightButton = item.rightBarButtonItem {
                            rightButton.target = self
                            rightButton.action = #selector(rightButtonAction)
                        }
                    }
                }
                stackNavBars.append(navbar)
            }
        }
    }

    private func setupViewControllers() {
        stackPageVC = [UIViewController]()
        stackVC.enumerated().forEach { index, viewController in
            let pageViewController = UIViewController()
            viewController.view.frame = pageViewController.view.bounds
            viewController.view.autoresizingMask = [
                .flexibleWidth,
                .flexibleHeight
            ]
            if !navigationBarShouldBeOnBottom && !navigationBarShouldNotExist {
                viewController.view.frame.origin.y += Constants.navigationBarHeight
                viewController.view.frame.size.height -= Constants.navigationBarHeight
            }
            pageViewController.addChild(viewController)
            pageViewController.view.addSubview(viewController.view)
            viewController.didMove(toParent: pageViewController)
            if !stackNavBars.isEmpty {
                pageViewController.view.addSubview(stackNavBars[index])
            }
            stackPageVC.append(pageViewController)
        }
        
        currentStackVC = stackPageVC[stackStartLocation]
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([stackPageVC[stackStartLocation]], direction: .forward, animated: true, completion: nil)
        var pageViewControllerY: CGFloat = 0
        var pageViewControllerH: CGFloat = 0
        if navigationBarShouldNotExist {
            pageViewControllerY = 0
            pageViewControllerH = Constants.ScreenHeight
        } else {
            pageViewControllerY = Constants.StatusBarHeight
            pageViewControllerH = Constants.ScreenHeightWithoutStatusBar
        }
        pageViewController.view.frame = CGRect(x: 0, y: pageViewControllerY, width: Constants.ScreenWidth, height: pageViewControllerH)
        pageViewController.view.backgroundColor = UIColor.clear
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        self.setFrameForCurrentOrientation()
        pageViewController.didMove(toParent: self)
    }

    open func setupView() {

    }
    
    public func setFrameForCurrentOrientation() {
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    override open func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        
        stackVC = datasource?.viewControllerData()
        stackStartLocation = datasource?.indexOfStartingPage?() ?? 0
        guard stackVC != nil else {
            print("Problem: GaryPortalSwipeController needs ViewController Data, please implement GPSwipeControllerDataSource")
            return
        }
        
        setupNavigationBar()
        setupViewControllers()
        setupPageViewController()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.setFrameForCurrentOrientation()
    }
    
    @objc
    public func leftButtonAction() {
        
        let currentIndex = stackPageVC.firstIndex(of: currentStackVC)!
        datasource?.clickedLeftButtonFromPageIndex?(currentIndex)

        let shouldDisableSwipe = datasource?.disableSwipingForLeftButtonAtPageIndex?(currentIndex) ?? false
        if shouldDisableSwipe {
            return
        }

        if currentStackVC == stackPageVC.first {
            return
        }
        
        let newVCIndex = currentIndex - 1
        datasource?.changedToPageIndex?(newVCIndex)
        currentStackVC = stackPageVC[newVCIndex]
        pageViewController.setViewControllers([currentStackVC], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
    }

    @objc
    public func rightButtonAction() {
        let currentIndex = stackPageVC.firstIndex(of: currentStackVC)!
        datasource?.clickedRightButtonFromPageIndex?(currentIndex)

        let shouldDisableSwipe = datasource?.disableSwipingForRightButtonAtPageIndex?(currentIndex) ?? false
        if shouldDisableSwipe {
            return
        }

        if currentStackVC == stackPageVC.last {
            return
        }
        
        let newVCIndex = currentIndex + 1
        datasource?.changedToPageIndex?(newVCIndex)

        currentStackVC = stackPageVC[newVCIndex]
        pageViewController.setViewControllers([currentStackVC], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    }
    
    public func moveToPage(_ index: Int, animated: Bool) {
        let currentIndex = stackPageVC.firstIndex(of: currentStackVC)!
        
        var direction: UIPageViewController.NavigationDirection = .reverse
        
        if index > currentIndex {
            direction = .forward
        }
        
        datasource?.changedToPageIndex?(index)
        currentStackVC = stackPageVC[index]
        
        pageViewController.setViewControllers([currentStackVC], direction: direction, animated: animated, completion: nil)
    }
}

extension GaryPortalSwipeController: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == stackPageVC.first {
            return nil
        }
        return stackPageVC[stackPageVC.firstIndex(of: viewController)! - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == stackPageVC.last {
            return nil
        }
        return stackPageVC[stackPageVC.firstIndex(of: viewController)! + 1]
    }
}

extension GaryPortalSwipeController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        
        let newVCIndex = stackPageVC.firstIndex(of: pageViewController.viewControllers!.first!)!
        
        datasource?.changedToPageIndex?(newVCIndex)
        
        currentStackVC = stackPageVC[newVCIndex]
    }
    
    var statusBarOrientation: UIInterfaceOrientation? {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            #if DEBUG
            fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
            #else
            return nil
            #endif
        }
        return orientation
    }
}
