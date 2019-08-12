//
//  CatProdVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/5/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit

class CatProdVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var subViewControllers:[UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoriaView") as! CategoriaVC,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductoView") as! ProductoVC]
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        // Do any additional setup after loading the view.
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    
    
    
    
    
    //MARK - UIPageViewControllerDataSource
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex <= 0) {
            return nil
        }
        return subViewControllers[currentIndex-1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex >= subViewControllers.count-1) {
            return nil
        }
        return subViewControllers[currentIndex+1]
    }
    

    

}
