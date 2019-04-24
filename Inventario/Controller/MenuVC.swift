//
//  MenuVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 4/23/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class MenuVC: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        switch indexPath.row {
        case 0: NotificationCenter.default.post(name: NSNotification.Name("gotoConfiguracion"), object: nil)
        case 1: NotificationCenter.default.post(name: NSNotification.Name("gotoCatProd"), object: nil)
        case 2: NotificationCenter.default.post(name: NSNotification.Name("gotoProovedores"), object: nil)
        case 3: NotificationCenter.default.post(name: NSNotification.Name("gotoClientes"), object: nil)
        case 4: NotificationCenter.default.post(name: NSNotification.Name("gotoVisualizar"), object: nil)
        case 5: NotificationCenter.default.post(name: NSNotification.Name("gotoAlmacen"), object: nil)
        case 6: NotificationCenter.default.post(name: NSNotification.Name("gotoTraspaso"), object: nil)
        default: break
        }
    }

}
