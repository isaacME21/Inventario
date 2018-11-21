//
//  ProductoVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/5/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit

class ProductoVC: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 1

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SwipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
    }
    



}
