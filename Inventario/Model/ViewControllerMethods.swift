//
//  ViewControllerMethods.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 5/12/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension UIViewController{
    
    //TODO: ALERTAS PARA VERIFICACION
    func alertInput()  {
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Algunos de los campos estan vacios" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @objc func SwipeAction(swipe: UISwipeGestureRecognizer) {
        
        
        switch swipe.direction.rawValue {
        case 1:
            navigationController?.popToRootViewController(animated: true)
        case 2:
            performSegue(withIdentifier: "gotoRight", sender: self)
            
        default:
            break
        }
        
    }
    
    
}
