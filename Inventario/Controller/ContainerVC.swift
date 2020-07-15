//
//  ContainerVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 4/23/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {
    
    
    //MARK: EL CONTENEDOR DEL MENU
    ///ESTE CONTROLADOR SE ENCARGA DE LA ANIMACION DEL MENU.
    ///EL MENU SE MUESTRA DE MANERA LATERAL 
    var sideMenuOpen = false
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideMenu),
                                               name: NSNotification.Name("HideSideMenu"),
                                               object: nil)
    }
    
    
    @objc func toggleSideMenu(){
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuConstraint.constant = -300
            
        } else {
            sideMenuOpen = true
            sideMenuConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func hideMenu(){
        sideMenuOpen = false
        sideMenuConstraint.constant = -300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

}
